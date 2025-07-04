#!/bin/bash
set -e -o pipefail # exit on error

PROG_DIR=$(cd "${0%/*}" && pwd)
WORK_DIR=${PROG_DIR%/*} # parent dir of this script

IMAGE_NAME=harvester1.5.0

[[ $1 ]] && RES_IMAGE=$1 || RES_IMAGE="$WORK_DIR"/$IMAGE_NAME.dd
[[ ! -e "$RES_IMAGE" ]] || { echo "'$RES_IMAGE' already exist" >&2; exit 1; }

ORIG_ISO_IMAGE_CACHE_PATH="$WORK_DIR"/orig/$IMAGE_NAME.iso
[[ -e $ORIG_ISO_IMAGE_CACHE_PATH ]] || { echo "please download official Harvester OS image(*.iso) to $ORIG_ISO_IMAGE_CACHE_PATH."\
  " You can download it from https://releases.rancher.com/harvester/v1.5.0/harvester-v1.5.0-amd64.iso"; exit 1; }

[[ $(id -u) == 0 ]] || { >&2 echo "Please run under root user or prefix with sudo -E"; exit 1; }

set -x # enable command trace

# Note that the ! VAR=$(cmd...) does not mean VAR is empty or null, it just means the cmd failed(exit with non-zero status)
function kill_tmp_http_server() { ! HTTP_SERVER_PID=$(ss -ltnp 'sport = :10080' | grep servefile | grep -P -o '(?<=,pid=)\d+(?=,)' | head -n 1) || kill -9 $HTTP_SERVER_PID; }

type -p servefile >/dev/null || apt-get -y install servefile
type -p kvm >/dev/null || apt-get -y install qemu-kvm
# for KVM UEFI boot
[[ -e /usr/share/qemu/OVMF.fd ]] || apt-get -y install qvmf

"$PROG_DIR"/_cleanup.sh "$RES_IMAGE"
kill_tmp_http_server

{ echo -e "\e[32m--------------------------------------------------------------------------------\e[0m"; } >&2 2>/dev/null
mkdir -p "$RES_IMAGE".tmp

# start http server to serve the tmp dir so can provide config files to the liveos later
servefile -l -p 10080 "$RES_IMAGE".tmp > "$RES_IMAGE".tmp/http.log 2>&1 &

# Although we are using PXE boot installer mode (but directly specify kernel/initrd in KVM),
# the ISO file is still needed because the installer need use image repo in it.
# Besides, the kernel, initrd, rootfs.squashfs in the ISO are same as respective separate files
# in the official Harvester download page, so let use just extract them from the ISO to avoid
# wasting disk space.
mkdir -p "$RES_IMAGE".tmp/iso.mount
mount -o ro "$ORIG_ISO_IMAGE_CACHE_PATH" "$RES_IMAGE".tmp/iso.mount
ln -sfv "$ORIG_ISO_IMAGE_CACHE_PATH" "$RES_IMAGE".tmp/iso

# The kernel, initrd, rootfs.squashfs  in the ISO are same as respective separate files in the
# official Harvester download page.
ln -sfv "$RES_IMAGE".tmp/iso.mount/{boot/kernel,boot/initrd,rootfs.squashfs} "$RES_IMAGE".tmp/

rsync -av "$PROG_DIR"/${IMAGE_NAME}_files/liveos/. "$RES_IMAGE".tmp/

sleep 1;
date +"%Y%m%d%H%M%S%3N" | tee "$RES_IMAGE".tmp/test_timestamp
curl -fksSL http://localhost:10080/test_timestamp | grep -F -q -- "$(<"$RES_IMAGE".tmp/test_timestamp)"

{ echo -e "\e[32m--------------------------------------------------------------------------------\e[0m"; } >&2 2>/dev/null

# At least 250GB. Otherwise, harvester installer (in liveos) will reject installation.
IMG_SIZE=$((250*1024*1024*1024))
truncate --size=$IMG_SIZE "$RES_IMAGE"
sgdisk "$RES_IMAGE" --zap-all

# The 10.0.2.2 is the physical host from vm side view
LIVEOS_KERNEL_OPTS="ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 console=ttyS0 \
  root=live:http://10.0.2.2:10080/rootfs.squashfs \
  harvester.install.config_url=http://10.0.2.2:10080/harvester_install_config.yml \
  harvester.install.automatic=true harvester.install.skipchecks=true \
  "

# Start the liveos, which automatically install os to target disk ($RES_IMAGE).
# - The liveos user/password is rancher/rancher.
# - The liveos can be accessed via ``ssh rancher@localhost -p 10080``.
# - The installation log is in /var/log/console.log.
# - The installation starts from /system/oem/91_installer.yaml (https://github.com/harvester/harvester-installer/blob/v1.5.0/package/harvester-os/files/system/oem/91_installer.yaml#L5-L5),
#   then setup-installer.sh calls doInstall (https://github.com/harvester/harvester-installer/blob/v1.5.0/pkg/console/util.go#L509-L509),
#   the doInstall does some simple preparation then call ``harv-install`` (https://github.com/harvester/harvester-installer/blob/v1.5.0/pkg/console/util.go#L587).
# - The harvester related configuration is in harvester_install_config.yml. It does not matter much because this is just
#   a preinstallation, the configuration can be changed later.
#
# Details about the kvm parameters:
# - The ``-drive if=virtio,format=raw,...`` will become /dev/vda in the guest os. The v means virtio.
#   installer can directly mount it without downloading.
# - The ``-vnc :0`` means listen at port 5900+0. To view tty1, vnc is needed.
#   The ``password=on`` is needed for at least MacOS's VNC client which requires non-empty vnc password.
#   Please run ``nc -N localhost 10180 <<<"set_password vnc VNC_PASSWORD_HERE"`` before using VNC client.
#   Note: the ``-display vnc=...`` just does not work well, especially the above set_password does not work.
# - The ``-monitor ...`` defines a VM controller, which listen at port 10180
# - The ``-hostfwd ...`` forward host side port 22000 to guest os's 22(SSH).
#   Note: the liveos's login user/password is always rancher/rancher, regardless what password configured in the
#   harvester_install_config.yml.
# - The reason why define two ``-device ... -netdev ...`` is that the liveos's harvester installer require at least 2 nics.
# - The ``netdev user,...`` makes the vm can access outside network (QEUM builtin NAT bridge),
#   and the dns also works transparently(QEUM builtin DNS forwarder).
# - The ``-bios /usr/share/qemu/OVMF.fd`` is for booting in UEFI mode so that the automatic installer will create an
#   UEFI bootable image.
#   The harvester-installer does not install GRUB for both legacy and UEFI boot mode.
#   It is for harvester1.5.0_step1_prepare_dual_boot_image.sh. Comparing with inserting EFI partition later,
#   it is easier to install GRUB EFI stuff here and then let harvester1.5.0_step1_prepare_dual_boot_image.sh split the
#   EFI partition into a 1MB bios_grub partition and the rest EFI partition.
kvm -m 4G -cpu host -smp 2 -bios /usr/share/qemu/OVMF.fd \
  -serial stdio -vnc :0,password=on \
  -monitor telnet:127.0.0.1:10180,server,nowait \
  -drive if=virtio,format=raw,media=disk,file="$RES_IMAGE" \
  -kernel "$RES_IMAGE".tmp/kernel -initrd "$RES_IMAGE".tmp/initrd -append "$LIVEOS_KERNEL_OPTS" \
  -device virtio-net,netdev=mgmtNic,mac=52:54:00:ec:0e:0b -netdev user,id=mgmtNic,net=10.0.2.0/24,host=10.0.2.2,hostfwd=tcp::10022-:22 \
  -device virtio-net,netdev=userNic,mac=6e:87:e4:d9:e2:01 -netdev user,id=userNic,net=10.0.3.0/24,host=10.0.3.2

kill_tmp_http_server

# When the above kvm process is interrupted or killed, or VM is powered off by some wrong action,
# the kvm command does not exit as error.
#
# So we need to check if the installation really succeeded.
# The check can be achieved by following method:
#
# Find COS_OEM partition, show /install/console.log, which means installation success.
# Notes:
# - The ``blkid -L COS_OEM`` may output wrong result when there are multiple partitions have same label.
# - The the ``blkid -L COS_OEM $LOOP_DEV`` is a wrong usage, the $LOOP_DEV will not be used at all, the result device
#   may be completely of other devices.
# - The ``blkid -t LABEL="COS_OEM" -o device ${LOOP_DEV}p*`` can precisely find the partition in $LOOP_DEV.
LOOP_DEV=$(losetup --find --show --partscan "$RES_IMAGE") \
  && COS_OEM_PART_DEV=$(blkid -t LABEL=COS_OEM -o device ${LOOP_DEV}p*) \
  && mkdir -p "$RES_IMAGE".tmp/part-COS_OEM.mount \
  && mount -o ro $COS_OEM_PART_DEV "$RES_IMAGE".tmp/part-COS_OEM.mount \
  && cat "$RES_IMAGE".tmp/part-COS_OEM.mount/install/console.log \
  && OK=1
[[ $OK ]] || { echo -e "\e[31m[Error] Something wrong happened (such as the kvm is interrupted or killed). Could not confirm that the result image '$RES_IMAGE' has a partition with label 'COS_OEM' and has /install/console.log in it.'\e[0m"; } >&2 2>/dev/null

"$PROG_DIR"/_cleanup.sh "$RES_IMAGE" || [[ ! $OK ]] || { echo -e "\e[31m[Error] prepared UEFI-only bootable image '$RES_IMAGE', but failed to cleanup.\e[0m"; } >&2 2>/dev/null

[[ $OK ]] || exit 1 # Newbies: non-zero exit code (such as 1) actually means FAILURE !
{ echo -e "\e[32m[Done] prepared UEFI-only bootable image '$RES_IMAGE'\e[0m"; } >&2 2>/dev/null
