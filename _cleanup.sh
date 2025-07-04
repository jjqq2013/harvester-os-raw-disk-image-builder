#!/bin/bash
set -e -o pipefail # exit on error

function show_usage_then_abort() {
  >&2 echo "Usage:"
  >&2 echo "  ${0##*/} [IMAGE PATHs ...]"
  >&2 echo ""
  >&2 echo "This will clean all intermediate files(including loop devices, LVM devices) related to the image files specified by IMAGE PATHs."
  exit 1
}

[[ $1 == --help ]] && show_usage_then_abort

[[ $(id -u) == 0 ]] || { >&2 echo "Please run under root user or prefix with sudo"; exit 1; }

#set -x # enable command trace

function detach_loopdev() {
  local IMAGE_PATH=${1:?IMAGE_PATH}
  local IMAGE_FULL_PATH LOOP_DEV last_dev LVM_VG_INFOS CHANGED LVM_VG_NAME LVM_VG_UUID LV_PATHS LVM_LV_DEV
  IMAGE_FULL_PATH=$(readlink -f "$IMAGE_PATH")
  # find loop device backed up by the $IMAGE_PATH even if the file itself has been deleted
  while LOOP_DEV=$(losetup --list --output=NAME,BACK-FILE | grep -P '^/dev/loop[0-9]+ +\Q'"$IMAGE_FULL_PATH"'\E($| \(deleted\)$)' | awk '{print $1}' | head -n 1); do
    if [[ $LOOP_DEV == $last_dev ]]; then
      { printf "\e[32m%s\e[0m\n" "Could not detach loop device $LOOP_DEV ($IMAGE_FULL_PATH), the loop device or its sub devices are still being referenced(such as mounted to a dir) by other processes."; } >&2 2>/dev/null
      [[ $IGNORE_ERROR == 1 ]] || exit 1
      break
    else
      last_dev=$LOOP_DEV
    fi

    pvscan --cache >/dev/null 2>&1 || true # no need on newer OS such as Ubuntu Focal
    LVM_VG_INFOS=$(pvdisplay ${LOOP_DEV}p* $LOOP_DEV --columns --noheadings -o vg_name,vg_uuid 2>/dev/null || true)

    # unmount several times to solve the nest mount issue: sub mounts need be first unmounted
    CHANGED=1
    while [[ $CHANGED ]]; do
      CHANGED=""
      # unmount all mount points of the loop device and their sub devices
      for dev in ${LOOP_DEV}p* $LOOP_DEV; do
        while umount --verbose $dev 2>&1 | sed -E '/: (not mounted|no mount point specified).$/d'; do CHANGED=1; sleep 0.1; done
      done

      while read LVM_VG_NAME LVM_VG_UUID; do
        # unmount mounts of logical volume devices
        LV_PATHS=$(lvdisplay --columns --noheadings -o lv_path --select vg_uuid=$LVM_VG_UUID,lv_active=active)
        [[ ! $LV_PATHS ]] || while read LVM_LV_DEV; do
          while umount --verbose $LVM_LV_DEV 2>&1 | sed -E '/: (not mounted|no mount point specified).$/d'; do CHANGED=1; sleep 0.1; done
        done <<<"$LV_PATHS"
        if lvdisplay --columns --noheadings --select vg_uuid=$LVM_VG_UUID,lv_active=active | grep -q . ; then
          # deactivate the VG to notify kernel to delete /dev/mapper/<VG related devices> for inner logical volumes
          vgchange --activate n --select vg_uuid=$LVM_VG_UUID || break
          udevadm settle
          CHANGED=1
        fi
      done <<<"$LVM_VG_INFOS"
    done

    losetup --detach $LOOP_DEV 2>&1 | sed -E '/: No such device or address$/d' && echo "detached $LOOP_DEV ($IMAGE_FULL_PATH)"  || true
    udevadm settle
  done
}

# kill kvm associated with this image file
function kill_kvm() {
  local IMAGE_FULL_PATH
  IMAGE_FULL_PATH=$(readlink -f "${1:?IMAGE_PATH}")
  { find /proc -mindepth 2 -maxdepth 2 -path '/proc/[0-9]*/comm' -print0 2>/dev/null \
    | xargs -0 -n 4096 grep -F --line-regexp -l kvm 2>/dev/null \
    | grep -P -o '\d+' || true;
  } | while read pid; do
    ! { xargs -0 -n1 < /proc/$pid/cmdline | grep -P "\b\Qfile=$IMAGE_FULL_PATH\E\b"; } \
    || { echo Will kill $pid; { kill -KILL $pid; sleep 0.2s; } || true; };
  done
}

PROG_DIR=$(cd "${0%/*}" && pwd)
WORK_DIR=${PROG_DIR%/*} # parent dir of this script

[[ $# != 0 ]] && IMAGE_PATHS=("$@") || IMAGE_PATHS=("$WORK_DIR/"*.dd)
for IMAGE_PATH in "${IMAGE_PATHS[@]}"; do
  detach_loopdev "$IMAGE_PATH"
  # remove all possible mount points associated with the loop device of the IMAGE_PATH.
  for d in "$IMAGE_PATH".{rootfs,efi,mount,xfs,oem,tmp/part-COS_OEM.mount}; do
    ! mountpoint -q "$d" || { echo "the dir '$d' is still a mount point, will no delete."; continue; };
    rm -frv "$d"
  done

  # kill kvm associated with this image file
  kill_kvm "$IMAGE_PATH"

  # remove mount points associated with the loop device of the ISO file.
  ! mountpoint -q "$IMAGE_PATH".tmp/iso.mount || umount "$IMAGE_PATH".tmp/iso.mount
  rm -frv "$IMAGE_PATH".tmp

done
# if no any arguments specified, then also delete all intermediate image files
[[ $# != 0 ]] || rm -frv "$WORK_DIR/"*.dd.{orig,new_xfs.dd}
