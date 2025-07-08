# harvester-os-raw-disk-image-builder
Build harvester os raw disk image

The scripts are tested on Ubuntu Noble(24.04), but could be run on any Debian based OS.

- **First-time-only**: Download the ISO file to orig/harvester1.5.0.iso
```
mkdir ./orig
curl -fksSL https://releases.rancher.com/harvester/v1.5.0/harvester-v1.5.0-amd64.iso -o ./orig/harvester1.5.0.iso
```

- **First-time-only**: Download this repo to ./bin dir
```
git clone https://github.com/jjqq2013/harvester-os-raw-disk-image-builder.git ./bin
```

- Run following command to install Harvester OS to `./harvester1.5.0.dd` (raw disk image).
```
sudo ./bin/harvester1.5.0_step0_prepare_uefi_only_boot_image.sh
```

To abort the above program, you can press CTRL+C.


Here is the output of the above script (skipped some too verbose output), the last part (search `console.log`) is the output of the harvester installer.

```
# bin/harvester1.5.0_step0_prepare_uefi_only_boot_image.sh
+ type -p servefile
+ type -p kvm
+ [[ -e /usr/share/qemu/OVMF.fd ]]
+ /srv/repos/os_images/bin/_cleanup.sh /srv/repos/os_images/harvester1.5.0.dd
+ kill_tmp_http_server
++ ss -ltnp 'sport = :10080'
++ grep servefile
++ grep -P -o '(?<=,pid=)\d+(?=,)'
++ head -n 1
+ HTTP_SERVER_PID=
--------------------------------------------------------------------------------
+ mkdir -p /srv/repos/os_images/harvester1.5.0.dd.tmp
+ mkdir -p /srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount
+ servefile -l -p 10080 /srv/repos/os_images/harvester1.5.0.dd.tmp
+ mount -o ro /srv/repos/os_images/orig/harvester1.5.0.iso /srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount
+ ln -sfv /srv/repos/os_images/orig/harvester1.5.0.iso /srv/repos/os_images/harvester1.5.0.dd.tmp/iso
'/srv/repos/os_images/harvester1.5.0.dd.tmp/iso' -> '/srv/repos/os_images/orig/harvester1.5.0.iso'
+ ln -sfv /srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount/boot/kernel /srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount/boot/initrd /srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount/rootfs.squashfs /srv/repos/os_images/harvester1.5.0.dd.tmp/
'/srv/repos/os_images/harvester1.5.0.dd.tmp/kernel' -> '/srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount/boot/kernel'
'/srv/repos/os_images/harvester1.5.0.dd.tmp/initrd' -> '/srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount/boot/initrd'
'/srv/repos/os_images/harvester1.5.0.dd.tmp/rootfs.squashfs' -> '/srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount/rootfs.squashfs'
+ rsync -av /srv/repos/os_images/bin/harvester1.5.0/. /srv/repos/os_images/harvester1.5.0.dd.tmp/
sending incremental file list
./
ctr-check-images.sh
ctr-check-images.sh.orig
harv-install
harv-install.orig
harvester_install_config.yml
liveos_cloud_config_for_fixing_harv_install.yml

sent 40,574 bytes  received 133 bytes  81,414.00 bytes/sec
total size is 40,018  speedup is 0.98
+ sleep 1
+ date +%Y%m%d%H%M%S%3N
+ tee /srv/repos/os_images/harvester1.5.0.dd.tmp/test_timestamp
20250706031723057
+ curl -fksSL http://localhost:10080/test_timestamp
+ grep -F -q -- 20250706031723057
--------------------------------------------------------------------------------
+ IMG_SIZE=268435456000
+ truncate --size=268435456000 /srv/repos/os_images/harvester1.5.0.dd
+ sgdisk /srv/repos/os_images/harvester1.5.0.dd --zap-all
Creating new GPT entries in memory.
Warning: The kernel is still using the old partition table.
The new table will be used at the next reboot or after you
run partprobe(8) or kpartx(8)
GPT data structures destroyed! You may now partition the disk using fdisk or
other utilities.
+ LIVEOS_KERNEL_OPTS='ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 console=ttyS0   root=live:http://10.0.2.2:10080/rootfs.squashfs   harvester.install.config_url=http://10.0.2.2:10080/harvester_install_config.yml   harvester.install.automatic=true harvester.install.skipchecks=true   cos.setup=http://10.0.2.2:10080/liveos_cloud_config_for_fixing_harv_install.yml'
+ kvm -m 4G -cpu host -smp 2 -bios /usr/share/qemu/OVMF.fd -serial stdio -vnc :0,password=on -monitor telnet:127.0.0.1:10180,server,nowait -drive if=virtio,format=raw,media=disk,file=/srv/repos/os_images/harvester1.5.0.dd -drive if=virtio,format=raw,media=cdrom,file=/srv/repos/os_images/orig/harvester1.5.0.iso -kernel /srv/repos/os_images/harvester1.5.0.dd.tmp/kernel -initrd /srv/repos/os_images/harvester1.5.0.dd.tmp/initrd -append 'ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 console=ttyS0   root=live:http://10.0.2.2:10080/rootfs.squashfs   harvester.install.config_url=http://10.0.2.2:10080/harvester_install_config.yml   harvester.install.automatic=true harvester.install.skipchecks=true   cos.setup=http://10.0.2.2:10080/liveos_cloud_config_for_fixing_harv_install.yml' -device virtio-net,netdev=mgmtNic,mac=52:54:00:ec:0e:0b -netdev user,id=mgmtNic,net=10.0.2.0/24,host=10.0.2.2,hostfwd=tcp::10022-:22 -device virtio-net,netdev=userNic,mac=6e:87:e4:d9:e2:01 -netdev user,id=userNic,net=10.0.3.0/24,host=10.0.3.2
[W][19843.961825] pw.conf      | [          conf.c: 1020 try_load_conf()] can't load config client.conf: No such file or directory
[E][19843.961945] pw.conf      | [          conf.c: 1049 pw_conf_load_conf_for_context()] can't load config client.conf: No such file or directory
EFI stub: Loaded initrd from LINUX_EFI_INITRD_MEDIA_GUID device path
[    0.000000][    T0] Linux version 5.14.21-150500.55.100-default (geeko@buildhost) (gcc (SUSE Linux) 7.5.0, GNU ld (GNU Binutils; SUSE Linux Enterprise 15) 2.43.1.20241209-150100.7.52) #1 SMP PREEMPT_DYNAMIC Thu Apr 3 17:03:15 UTC 2025 (a9fe8f3)
[    0.000000][    T0] Command line: ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 console=ttyS0   root=live:http://10.0.2.2:10080/rootfs.squashfs   harvester.install.config_url=http://10.0.2.2:10080/harvester_install_config.yml   harvester.install.automatic=true harvester.install.skipchecks=true   cos.setup=http://10.0.2.2:10080/liveos_cloud_config_for_fixing_harv_install.yml initrd=initrd
[    0.000000][    T0] BIOS-provided physical RAM map:
[    0.000000][    T0] BIOS-e820: [mem 0x0000000000000000-0x000000000009ffff] usable
[    0.000000][    T0] BIOS-e820: [mem 0x0000000000100000-0x00000000007fffff] usable
[    0.000000][    T0] BIOS-e820: [mem 0x0000000000800000-0x0000000000807fff] ACPI NVS
[    0.000000][    T0] BIOS-e820: [mem 0x0000000000808000-0x000000000080afff] usable
[    0.000000][    T0] BIOS-e820: [mem 0x000000000080b000-0x000000000080bfff] ACPI NVS
[    0.000000][    T0] BIOS-e820: [mem 0x000000000080c000-0x000000000080ffff] usable
[    0.000000][    T0] BIOS-e820: [mem 0x0000000000810000-0x00000000008fffff] ACPI NVS
[    0.000000][    T0] BIOS-e820: [mem 0x0000000000900000-0x00000000bed3efff] usable
[    0.000000][    T0] BIOS-e820: [mem 0x00000000bed3f000-0x00000000bedfffff] reserved
[    0.000000][    T0] BIOS-e820: [mem 0x00000000bee00000-0x00000000bf8ecfff] usable
[    0.000000][    T0] BIOS-e820: [mem 0x00000000bf8ed000-0x00000000bfb6cfff] reserved
[    0.000000][    T0] BIOS-e820: [mem 0x00000000bfb6d000-0x00000000bfb7efff] ACPI data
[    0.000000][    T0] BIOS-e820: [mem 0x00000000bfb7f000-0x00000000bfbfefff] ACPI NVS
[    0.000000][    T0] BIOS-e820: [mem 0x00000000bfbff000-0x00000000bfeebfff] usable
[    0.000000][    T0] BIOS-e820: [mem 0x00000000bfeec000-0x00000000bff6ffff] reserved
[    0.000000][    T0] BIOS-e820: [mem 0x00000000bff70000-0x00000000bfffffff] ACPI NVS
[    0.000000][    T0] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000][    T0] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000][    T0] NX (Execute Disable) protection: active
[    0.000000][    T0] extended physical RAM map:
[    0.000000][    T0] reserve setup_data: [mem 0x0000000000000000-0x000000000009ffff] usable
[    0.000000][    T0] reserve setup_data: [mem 0x0000000000100000-0x00000000007fffff] usable
[    0.000000][    T0] reserve setup_data: [mem 0x0000000000800000-0x0000000000807fff] ACPI NVS
[    0.000000][    T0] reserve setup_data: [mem 0x0000000000808000-0x000000000080afff] usable
[    0.000000][    T0] reserve setup_data: [mem 0x000000000080b000-0x000000000080bfff] ACPI NVS
[    0.000000][    T0] reserve setup_data: [mem 0x000000000080c000-0x000000000080ffff] usable
[    0.000000][    T0] reserve setup_data: [mem 0x0000000000810000-0x00000000008fffff] ACPI NVS
[    0.000000][    T0] reserve setup_data: [mem 0x0000000000900000-0x00000000bdc3c017] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bdc3c018-0x00000000bdc6e457] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bdc6e458-0x00000000bdc6f017] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bdc6f018-0x00000000bdca1457] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bdca1458-0x00000000bdca2017] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bdca2018-0x00000000bdcaba57] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bdcaba58-0x00000000bed3efff] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bed3f000-0x00000000bedfffff] reserved
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bee00000-0x00000000bf8ecfff] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bf8ed000-0x00000000bfb6cfff] reserved
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bfb6d000-0x00000000bfb7efff] ACPI data
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bfb7f000-0x00000000bfbfefff] ACPI NVS
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bfbff000-0x00000000bfeebfff] usable
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bfeec000-0x00000000bff6ffff] reserved
[    0.000000][    T0] reserve setup_data: [mem 0x00000000bff70000-0x00000000bfffffff] ACPI NVS
[    0.000000][    T0] reserve setup_data: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000][    T0] reserve setup_data: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000][    T0] efi: EFI v2.70 by Ubuntu distribution of EDK II
[    0.000000][    T0] efi: SMBIOS=0xbf988000 SMBIOS 3.0=0xbf986000 ACPI=0xbfb7e000 ACPI 2.0=0xbfb7e014 MEMATTR=0xbdcac018 INITRD=0xbdcaef98
[    0.000000][    T0] secureboot: Secure boot disabled
[    0.000000][    T0] SMBIOS 3.0.0 present.
[    0.000000][    T0] DMI: QEMU Ubuntu 24.04 PC (i440FX + PIIX, 1996), BIOS 2024.02-2 03/11/2024
[    0.000000][    T0] Hypervisor detected: KVM
[    0.000000][    T0] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000][    T0] kvm-clock: cpu 0, msr 5fe02001, primary cpu clock
[    0.000001][    T0] kvm-clock: using sched offset of 870102297 cycles
[    0.000003][    T0] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000006][    T0] tsc: Detected 3491.914 MHz processor
[    0.000088][    T0] last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000117][    T0] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT
[    0.000123][    T0] last_pfn = 0xbfeec max_arch_pfn = 0x400000000
[    0.014119][    T0] Using GB pages for direct mapping
[    0.014687][    T0] secureboot: Secure boot disabled
[    0.014689][    T0] RAMDISK: [mem 0xac9a3000-0xb23b5fff]
[    0.014693][    T0] ACPI: Early table checksum verification disabled
[    0.014697][    T0] ACPI: RSDP 0x00000000BFB7E014 000024 (v02 BOCHS )
[    0.014702][    T0] ACPI: XSDT 0x00000000BFB7D0E8 00004C (v01 BOCHS  BXPC     00000001      01000013)
[    0.014708][    T0] ACPI: FACP 0x00000000BFB7A000 000074 (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.014717][    T0] ACPI: DSDT 0x00000000BFB7B000 001B19 (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.014723][    T0] ACPI: FACS 0x00000000BFBDD000 000040
[    0.014726][    T0] ACPI: APIC 0x00000000BFB79000 000080 (v03 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.014730][    T0] ACPI: HPET 0x00000000BFB78000 000038 (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.014734][    T0] ACPI: WAET 0x00000000BFB77000 000028 (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.014738][    T0] ACPI: BGRT 0x00000000BFB76000 000038 (v01 INTEL  EDK2     00000002      01000013)
[    0.014741][    T0] ACPI: Reserving FACP table memory at [mem 0xbfb7a000-0xbfb7a073]
[    0.014743][    T0] ACPI: Reserving DSDT table memory at [mem 0xbfb7b000-0xbfb7cb18]
[    0.014744][    T0] ACPI: Reserving FACS table memory at [mem 0xbfbdd000-0xbfbdd03f]
[    0.014745][    T0] ACPI: Reserving APIC table memory at [mem 0xbfb79000-0xbfb7907f]
[    0.014746][    T0] ACPI: Reserving HPET table memory at [mem 0xbfb78000-0xbfb78037]
[    0.014747][    T0] ACPI: Reserving WAET table memory at [mem 0xbfb77000-0xbfb77027]
[    0.014748][    T0] ACPI: Reserving BGRT table memory at [mem 0xbfb76000-0xbfb76037]
[    0.015018][    T0] No NUMA configuration found
[    0.015020][    T0] Faking a node at [mem 0x0000000000000000-0x000000013fffffff]
[    0.015029][    T0] NODE_DATA(0) allocated [mem 0x13ffd3000-0x13fffdfff]
[    0.015334][    T0] Zone ranges:
[    0.015335][    T0]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.015337][    T0]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.015339][    T0]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.015341][    T0]   Device   empty
[    0.015342][    T0] Movable zone start for each node
[    0.015345][    T0] Early memory node ranges
[    0.015346][    T0]   node   0: [mem 0x0000000000001000-0x000000000009ffff]
[    0.015347][    T0]   node   0: [mem 0x0000000000100000-0x00000000007fffff]
[    0.015348][    T0]   node   0: [mem 0x0000000000808000-0x000000000080afff]
[    0.015349][    T0]   node   0: [mem 0x000000000080c000-0x000000000080ffff]
[    0.015350][    T0]   node   0: [mem 0x0000000000900000-0x00000000bed3efff]
[    0.015351][    T0]   node   0: [mem 0x00000000bee00000-0x00000000bf8ecfff]
[    0.015352][    T0]   node   0: [mem 0x00000000bfbff000-0x00000000bfeebfff]
[    0.015353][    T0]   node   0: [mem 0x0000000100000000-0x000000013fffffff]
[    0.015355][    T0] Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
[    0.015368][    T0] On node 0, zone DMA: 1 pages in unavailable ranges
[    0.015436][    T0] On node 0, zone DMA: 96 pages in unavailable ranges
[    0.015440][    T0] On node 0, zone DMA: 8 pages in unavailable ranges
[    0.015442][    T0] On node 0, zone DMA: 1 pages in unavailable ranges
[    0.015514][    T0] On node 0, zone DMA: 240 pages in unavailable ranges
[    0.042982][    T0] On node 0, zone DMA32: 193 pages in unavailable ranges
[    0.043046][    T0] On node 0, zone DMA32: 786 pages in unavailable ranges
[    0.044230][    T0] On node 0, zone Normal: 276 pages in unavailable ranges
[    0.044591][    T0] ACPI: PM-Timer IO Port: 0xb008
[    0.044607][    T0] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.044645][    T0] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.044649][    T0] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.044651][    T0] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.044653][    T0] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.044654][    T0] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.044655][    T0] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.044660][    T0] ACPI: Using ACPI (MADT) for SMP configuration information
[    0.044661][    T0] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.044695][    T0] TSC deadline timer available
[    0.044703][    T0] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.044721][    T0] kvm-guest: KVM setup pv remote TLB flush
[    0.044724][    T0] kvm-guest: setup PV sched yield
[    0.044737][    T0] PM: hibernation: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.044740][    T0] PM: hibernation: Registered nosave memory: [mem 0x000a0000-0x000fffff]
[    0.044741][    T0] PM: hibernation: Registered nosave memory: [mem 0x00800000-0x00807fff]
[    0.044743][    T0] PM: hibernation: Registered nosave memory: [mem 0x0080b000-0x0080bfff]
[    0.044745][    T0] PM: hibernation: Registered nosave memory: [mem 0x00810000-0x008fffff]
[    0.044746][    T0] PM: hibernation: Registered nosave memory: [mem 0xbdc3c000-0xbdc3cfff]
[    0.044751][    T0] PM: hibernation: Registered nosave memory: [mem 0xbdc6e000-0xbdc6efff]
[    0.044753][    T0] PM: hibernation: Registered nosave memory: [mem 0xbdc6f000-0xbdc6ffff]
[    0.044754][    T0] PM: hibernation: Registered nosave memory: [mem 0xbdca1000-0xbdca1fff]
[    0.044755][    T0] PM: hibernation: Registered nosave memory: [mem 0xbdca2000-0xbdca2fff]
[    0.044757][    T0] PM: hibernation: Registered nosave memory: [mem 0xbdcab000-0xbdcabfff]
[    0.044759][    T0] PM: hibernation: Registered nosave memory: [mem 0xbdcb0000-0xbdcb8fff]
[    0.044760][    T0] PM: hibernation: Registered nosave memory: [mem 0xbed3f000-0xbedfffff]
[    0.044762][    T0] PM: hibernation: Registered nosave memory: [mem 0xbf8ed000-0xbfb6cfff]
[    0.044763][    T0] PM: hibernation: Registered nosave memory: [mem 0xbfb6d000-0xbfb7efff]
[    0.044764][    T0] PM: hibernation: Registered nosave memory: [mem 0xbfb7f000-0xbfbfefff]
[    0.044766][    T0] PM: hibernation: Registered nosave memory: [mem 0xbfeec000-0xbff6ffff]
[    0.044767][    T0] PM: hibernation: Registered nosave memory: [mem 0xbff70000-0xbfffffff]
[    0.044768][    T0] PM: hibernation: Registered nosave memory: [mem 0xc0000000-0xfeffbfff]
[    0.044769][    T0] PM: hibernation: Registered nosave memory: [mem 0xfeffc000-0xfeffffff]
[    0.044770][    T0] PM: hibernation: Registered nosave memory: [mem 0xff000000-0xffffffff]
[    0.044771][    T0] [mem 0xc0000000-0xfeffbfff] available for PCI devices
[    0.044773][    T0] Booting paravirtualized kernel on KVM
[    0.044776][    T0] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.048746][    T0] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
[    0.049885][    T0] percpu: Embedded 63 pages/cpu s221184 r8192 d28672 u1048576
[    0.049925][    T0] kvm-guest: setup async PF for cpu 0
[    0.049929][    T0] kvm-guest: stealtime: cpu 0, msr 13bc35080
[    0.049932][    T0] kvm-guest: PV spinlocks enabled
[    0.049935][    T0] PV qspinlock hash table entries: 256 (order: 0, 4096 bytes, linear)
[    0.049941][    T0] Fallback order for Node 0: 0
[    0.049944][    T0] Built 1 zonelists, mobility grouping on.  Total pages: 1028664
[    0.049946][    T0] Policy zone: Normal
[    0.049948][    T0] Kernel command line: ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 console=ttyS0   root=live:http://10.0.2.2:10080/rootfs.squashfs   harvester.install.config_url=http://10.0.2.2:10080/harvester_install_config.yml   harvester.install.automatic=true harvester.install.skipchecks=true   cos.setup=http://10.0.2.2:10080/liveos_cloud_config_for_fixing_harv_install.yml initrd=initrd
[    0.050111][    T0] Unknown kernel command line parameters "ip=dhcp", will be passed to user space.
[    0.052383][    T0] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes, linear)
[    0.053450][    T0] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    0.053517][    T0] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.053522][    T0] software IO TLB: area num 2.
[    0.078066][    T0] Memory: 2920024K/4187900K available (14336K kernel code, 3424K rwdata, 9412K rodata, 2884K init, 18096K bss, 423340K reserved, 0K cma-reserved)
[    0.078076][    T0] random: get_random_u64 called from __kmem_cache_create+0x28/0x470 with crng_init=0
[    0.078232][    T0] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.078250][    T0] Kernel/User page tables isolation: enabled
[    0.078304][    T0] ftrace: allocating 43330 entries in 170 pages
[    0.095734][    T0] ftrace: allocated 170 pages with 4 groups
[    0.096491][    T0] Dynamic Preempt: none
[    0.096523][    T0] rcu: Preemptible hierarchical RCU implementation.
[    0.096525][    T0] rcu:     RCU event tracing is enabled.
[    0.096526][    T0] rcu:     RCU restricting CPUs from NR_CPUS=8192 to nr_cpu_ids=2.
[    0.096528][    T0]  Trampoline variant of Tasks RCU enabled.
[    0.096528][    T0]  Rude variant of Tasks RCU enabled.
[    0.096529][    T0]  Tracing variant of Tasks RCU enabled.
[    0.096530][    T0] rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
[    0.096531][    T0] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=2
[    0.100152][    T0] NR_IRQS: 524544, nr_irqs: 440, preallocated irqs: 16
[    0.100374][    T0] random: crng done (trusting CPU's manufacturer)
[    0.100408][    T0] Console: colour dummy device 80x25
[    0.100671][    T0] printk: console [tty1] enabled
[    0.262450][    T0] printk: console [ttyS0] enabled
[    0.263059][    T0] ACPI: Core revision 20220331
[    0.263760][    T0] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.265002][    T0] APIC: Switch to symmetric I/O mode setup
[    0.265904][    T0] x2apic enabled
[    0.266552][    T0] Switched APIC routing to physical x2apic.
[    0.267235][    T0] kvm-guest: setup PV IPIs
[    0.268776][    T0] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.269635][    T0] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x32557ae966b, max_idle_ns: 440795369289 ns
[    0.270962][    T0] Calibrating delay loop (skipped) preset value.. 6983.82 BogoMIPS (lpj=13967656)
[    0.272091][    T0] x86/cpu: User Mode Instruction Prevention (UMIP) activated
[    0.274972][    T0] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.275684][    T0] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.276487][    T0] Spectre V1 : Mitigation: usercopy/swapgs barriers and __user pointer sanitization
[    0.277575][    T0] Spectre V2 : Mitigation: Retpolines
[    0.278205][    T0] Spectre V2 : Spectre v2 / SpectreRSB mitigation: Filling RSB on context switch
[    0.278961][    T0] Spectre V2 : Spectre v2 / SpectreRSB : Filling RSB on VMEXIT
[    0.279839][    T0] Speculative Store Bypass: Vulnerable
[    0.280448][    T0] MDS: Vulnerable: Clear CPU buffers attempted, no microcode
[    0.281300][    T0] MMIO Stale Data: Unknown: No mitigations
[    0.281962][    T0] SRBDS: Unknown: Dependent on hypervisor status
[    0.282973][    T0] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
[    0.283952][    T0] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
[    0.284781][    T0] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
[    0.285596][    T0] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
[    0.286401][    T0] x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'standard' format.
[    0.299911][    T0] Freeing SMP alternatives memory: 36K
[    0.300586][    T0] pid_max: default: 32768 minimum: 301
[    0.305189][    T0] LSM: Security Framework initializing
[    0.305932][    T0] AppArmor: AppArmor initialized
[    0.306604][    T0] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.307005][    T0] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.308499][    T1] smpboot: CPU0: Intel(R) Xeon(R) CPU E3-1241 v3 @ 3.50GHz (family: 0x6, model: 0x3c, stepping: 0x3)
[    0.310080][    T1] Performance Events: Haswell events, full-width counters, Intel PMU driver.
[    0.310959][    T1] ... version:                2
[    0.310959][    T1] ... bit width:              48
[    0.310959][    T1] ... generic registers:      4
[    0.310963][    T1] ... value mask:             0000ffffffffffff
[    0.311667][    T1] ... max period:             00007fffffffffff
[    0.312388][    T1] ... fixed-purpose events:   3
[    0.312944][    T1] ... event mask:             000000070000000f
[    0.313772][    T1] signal: max sigframe size: 1776
[    0.314395][    T1] rcu: Hierarchical SRCU implementation.
[    0.315512][    T1] smp: Bringing up secondary CPUs ...
[    0.316418][    T1] x86: Booting SMP configuration:
[    0.317012][    T1] .... node  #0, CPUs:      #1
[    0.170608][    T0] kvm-clock: cpu 1, msr 5fe02041, secondary cpu clock
[    0.317779][   T19] kvm-guest: setup async PF for cpu 1
[    0.317779][   T19] kvm-guest: stealtime: cpu 1, msr 13bd35080
[    0.318978][    T1] smp: Brought up 1 node, 2 CPUs
[    0.319671][    T1] smpboot: Max logical packages: 1
[    0.320366][    T1] smpboot: Total of 2 processors activated (13967.65 BogoMIPS)
[    0.325048][   T25] node 0 deferred pages initialised in 8ms
[    0.327336][    T1] devtmpfs: initialized
[    0.327590][    T1] x86/mm: Memory block size: 128MB
[    0.331006][    T1] ACPI: PM: Registering ACPI NVS region [mem 0x00800000-0x00807fff] (32768 bytes)
[    0.332325][    T1] ACPI: PM: Registering ACPI NVS region [mem 0x0080b000-0x0080bfff] (4096 bytes)
[    0.333571][    T1] ACPI: PM: Registering ACPI NVS region [mem 0x00810000-0x008fffff] (983040 bytes)
[    0.334832][    T1] ACPI: PM: Registering ACPI NVS region [mem 0xbfb7f000-0xbfbfefff] (524288 bytes)
[    0.334968][    T1] ACPI: PM: Registering ACPI NVS region [mem 0xbff70000-0xbfffffff] (589824 bytes)
[    0.336289][    T1] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.337739][    T1] futex hash table entries: 512 (order: 3, 32768 bytes, linear)
[    0.338841][    T1] pinctrl core: initialized pinctrl subsystem
[    0.339109][    T1] PM: RTC time: 03:17:25, date: 2025-07-06
[    0.341441][    T1] NET: Registered PF_NETLINK/PF_ROUTE protocol family
[    0.342464][    T1] DMA: preallocated 512 KiB GFP_KERNEL pool for atomic allocations
[    0.342973][    T1] DMA: preallocated 512 KiB GFP_KERNEL|GFP_DMA pool for atomic allocations
[    0.344158][    T1] DMA: preallocated 512 KiB GFP_KERNEL|GFP_DMA32 pool for atomic allocations
[    0.345362][    T1] audit: initializing netlink subsys (disabled)
[    0.346208][   T30] audit: type=2000 audit(1751771845.537:1): state=initialized audit_enabled=0 res=1
[    0.346208][    T1] thermal_sys: Registered thermal governor 'fair_share'
[    0.346968][    T1] thermal_sys: Registered thermal governor 'bang_bang'
[    0.347911][    T1] thermal_sys: Registered thermal governor 'step_wise'
[    0.348838][    T1] thermal_sys: Registered thermal governor 'user_space'
[    0.349764][    T1] cpuidle: using governor ladder
[    0.350967][    T1] cpuidle: using governor menu
[    0.351764][    T1] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.352857][    T1] PCI: Using configuration type 1 for base access
[    0.353717][    T1] core: PMU erratum BJ122, BV98, HSD29 workaround disabled, HT off
[    0.355580][    T1] kprobes: kprobe jump-optimization is enabled. All kprobes are optimized if possible.
[    0.356832][    T1] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
[    0.356832][    T1] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.416319][    T1] ACPI: Added _OSI(Module Device)
[    0.416319][    T1] ACPI: Added _OSI(Processor Device)
[    0.416319][    T1] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.416319][    T1] ACPI: Added _OSI(Processor Aggregator Device)
[    0.416919][    T1] ACPI: Added _OSI(Linux-Dell-Video)
[    0.417797][    T1] ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)
[    0.418840][    T1] ACPI: Added _OSI(Linux-HPI-Hybrid-Graphics)
[    0.423759][    T1] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.425271][    T1] ACPI: Interpreter enabled
[    0.425271][    T1] ACPI: PM: (supports S0 S3 S4 S5)
[    0.426965][    T1] ACPI: Using IOAPIC for interrupt routing
[    0.427870][    T1] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.429397][    T1] PCI: Ignoring E820 reservations for host bridge windows
[    0.430544][    T1] ACPI: Enabled 2 GPEs in block 00 to 0F
[    0.433065][    T1] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.434110][    T1] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI EDR HPX-Type3]
[    0.434964][    T1] acpi PNP0A03:00: _OSC: not requesting OS control; OS requires [ExtendedConfig ASPM ClockPM MSI]
[    0.436465][    T1] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.438510][    T1] acpiphp: Slot [3] registered
[    0.438981][    T1] acpiphp: Slot [4] registered
[    0.439656][    T1] acpiphp: Slot [5] registered
[    0.440304][    T1] acpiphp: Slot [6] registered
[    0.440966][    T1] acpiphp: Slot [7] registered
[    0.441656][    T1] acpiphp: Slot [8] registered
[    0.442337][    T1] acpiphp: Slot [9] registered
[    0.442981][    T1] acpiphp: Slot [10] registered
[    0.443660][    T1] acpiphp: Slot [11] registered
[    0.444332][    T1] acpiphp: Slot [12] registered
[    0.444987][    T1] acpiphp: Slot [13] registered
[    0.445660][    T1] acpiphp: Slot [14] registered
[    0.446304][    T1] acpiphp: Slot [15] registered
[    0.446980][    T1] acpiphp: Slot [16] registered
[    0.447670][    T1] acpiphp: Slot [17] registered
[    0.448326][    T1] acpiphp: Slot [18] registered
[    0.448988][    T1] acpiphp: Slot [19] registered
[    0.449661][    T1] acpiphp: Slot [20] registered
[    0.450322][    T1] acpiphp: Slot [21] registered
[    0.450982][    T1] acpiphp: Slot [22] registered
[    0.451689][    T1] acpiphp: Slot [23] registered
[    0.452359][    T1] acpiphp: Slot [24] registered
[    0.453011][    T1] acpiphp: Slot [25] registered
[    0.453673][    T1] acpiphp: Slot [26] registered
[    0.454368][    T1] acpiphp: Slot [27] registered
[    0.454978][    T1] acpiphp: Slot [28] registered
[    0.455651][    T1] acpiphp: Slot [29] registered
[    0.456337][    T1] acpiphp: Slot [30] registered
[    0.456979][    T1] acpiphp: Slot [31] registered
[    0.457656][    T1] PCI host bridge to bus 0000:00
[    0.458319][    T1] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.458963][    T1] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.460074][    T1] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.461226][    T1] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfebfffff window]
[    0.462329][    T1] pci_bus 0000:00: root bus resource [mem 0x7000000000-0x707fffffff window]
[    0.462962][    T1] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.463892][    T1] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.465172][    T1] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.466591][    T1] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.468632][    T1] pci 0000:00:01.1: reg 0x20: [io  0xc140-0xc14f]
[    0.470244][    T1] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.470963][    T1] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.471976][    T1] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.473049][    T1] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.474237][    T1] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.475324][    T1] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.476499][    T1] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.477738][    T1] pci 0000:00:02.0: [1234:1111] type 00 class 0x030000
[    0.491671][    T1] pci 0000:00:02.0: reg 0x10: [mem 0xc0000000-0xc0ffffff pref]
[    0.494253][    T1] pci 0000:00:02.0: reg 0x18: [mem 0xc1084000-0xc1084fff]
[    0.498196][    T1] pci 0000:00:02.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    0.499076][    T1] pci 0000:00:02.0: BAR 0: assigned to efifb
[    0.499742][    T1] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.501540][    T1] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.502950][    T1] pci 0000:00:03.0: reg 0x10: [io  0xc120-0xc13f]
[    0.503453][    T1] pci 0000:00:03.0: reg 0x14: [mem 0xc1083000-0xc1083fff]
[    0.505890][    T1] pci 0000:00:03.0: reg 0x20: [mem 0x7000000000-0x7000003fff 64bit pref]
[    0.507383][    T1] pci 0000:00:03.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[    0.509286][    T1] pci 0000:00:04.0: [1af4:1000] type 00 class 0x020000
[    0.511238][    T1] pci 0000:00:04.0: reg 0x10: [io  0xc100-0xc11f]
[    0.512435][    T1] pci 0000:00:04.0: reg 0x14: [mem 0xc1082000-0xc1082fff]
[    0.514678][    T1] pci 0000:00:04.0: reg 0x20: [mem 0x7000004000-0x7000007fff 64bit pref]
[    0.515496][    T1] pci 0000:00:04.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[    0.517326][    T1] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.518652][    T1] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0ff]
[    0.519823][    T1] pci 0000:00:05.0: reg 0x14: [mem 0xc1081000-0xc1081fff]
[    0.522698][    T1] pci 0000:00:05.0: reg 0x20: [mem 0x7000008000-0x700000bfff 64bit pref]
[    0.524569][    T1] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.525907][    T1] pci 0000:00:06.0: reg 0x10: [io  0xc000-0xc07f]
[    0.526968][    T1] pci 0000:00:06.0: reg 0x14: [mem 0xc1080000-0xc1080fff]
[    0.529612][    T1] pci 0000:00:06.0: reg 0x20: [mem 0x700000c000-0x700000ffff 64bit pref]
[    0.536761][    T1] ACPI: PCI: Interrupt link LNKA configured for IRQ 10
[    0.537644][    T1] ACPI: PCI: Interrupt link LNKB configured for IRQ 10
[    0.538471][    T1] ACPI: PCI: Interrupt link LNKC configured for IRQ 11
[    0.543071][    T1] ACPI: PCI: Interrupt link LNKD configured for IRQ 11
[    0.543864][    T1] ACPI: PCI: Interrupt link LNKS configured for IRQ 9
[    0.545049][    T1] iommu: Default domain type: Passthrough
[    0.545049][    T1] pps_core: LinuxPPS API ver. 1 registered
[    0.546970][    T1] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.548347][    T1] PTP clock support registered
[    0.549019][    T1] EDAC MC: Ver: 3.0.0
[    0.549678][    T1] Registered efivars operations
[    0.549678][    T1] NetLabel: Initializing
[    0.550964][    T1] NetLabel:  domain hash size = 128
[    0.551678][    T1] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
[    0.552567][    T1] NetLabel:  unlabeled traffic allowed by default
[    0.553397][    T1] PCI: Using ACPI for IRQ routing
[    0.555355][    T1] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.555951][    T1] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.558969][    T1] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.559797][    T1] vgaarb: loaded
[    0.567245][    T1] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.567980][    T1] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.575043][    T1] clocksource: Switched to clocksource kvm-clock
[    0.588455][    T1] VFS: Disk quotas dquot_6.6.0
[    0.589065][    T1] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.590056][    T1] AppArmor: AppArmor Filesystem Enabled
[    0.590665][    T1] pnp: PnP ACPI init
[    0.591451][    T1] pnp: PnP ACPI: found 6 devices
[    0.597874][    T1] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.599135][    T1] NET: Registered PF_INET protocol family
[    0.600091][    T1] IP idents hash table entries: 65536 (order: 7, 524288 bytes, linear)
[    0.601462][    T1] tcp_listen_portaddr_hash hash table entries: 2048 (order: 3, 32768 bytes, linear)
[    0.602499][    T1] TCP established hash table entries: 32768 (order: 6, 262144 bytes, linear)
[    0.603599][    T1] TCP bind hash table entries: 32768 (order: 7, 524288 bytes, linear)
[    0.604847][    T1] TCP: Hash tables configured (established 32768 bind 32768)
[    0.605839][    T1] MPTCP token hash table entries: 4096 (order: 4, 98304 bytes, linear)
[    0.606742][    T1] UDP hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.607594][    T1] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.608527][    T1] NET: Registered PF_UNIX/PF_LOCAL protocol family
[    0.609229][    T1] NET: Registered PF_XDP protocol family
[    0.609829][    T1] pci 0000:00:03.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[    0.610982][    T1] pci 0000:00:04.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[    0.612121][    T1] pci 0000:00:03.0: BAR 6: assigned [mem 0xc1000000-0xc107ffff pref]
[    0.612977][    T1] pci 0000:00:04.0: BAR 6: assigned [mem 0xc1100000-0xc117ffff pref]
[    0.613828][    T1] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.614566][    T1] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.615314][    T1] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    0.616130][    T1] pci_bus 0000:00: resource 7 [mem 0xc0000000-0xfebfffff window]
[    0.616952][    T1] pci_bus 0000:00: resource 8 [mem 0x7000000000-0x707fffffff window]
[    0.617847][    T1] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.618558][    T1] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.619296][    T1] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.620097][    T1] PCI: CLS 0 bytes, default 64
[    0.620611][    T1] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.620677][   T26] Trying to unpack rootfs image as initramfs...
[    0.621391][    T1] software IO TLB: mapped [mem 0x00000000b255b000-0x00000000b655b000] (64MB)
[    0.623134][    T1] ACPI: bus type thunderbolt registered
[    0.627020][    T1] RAPL PMU: API unit is 2^-32 Joules, 0 fixed counters, 10737418240 ms ovfl timer
[    0.628054][    T1] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x32557ae966b, max_idle_ns: 440795369289 ns
[    0.631472][    T1] Initialise system trusted keyrings
[    0.632082][    T1] Key type blacklist registered
[    0.635036][    T1] workingset: timestamp_bits=36 max_order=20 bucket_order=0
[    0.636930][    T1] zbud: loaded
[    0.637566][    T1] integrity: Platform Keyring initialized
[    1.081403][    T1] Key type asymmetric registered
[    1.081990][    T1] Asymmetric key parser 'x509' registered
[    1.082660][    T1] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 246)
[    1.083612][    T1] io scheduler mq-deadline registered
[    1.084195][    T1] io scheduler kyber registered
[    1.084739][    T1] io scheduler bfq registered
[    1.085552][    T1] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    1.101028][    T1] ACPI: \_SB_.LNKC: Enabled at IRQ 11
[    1.116499][    T1] ACPI: \_SB_.LNKD: Enabled at IRQ 10
[    1.131976][    T1] ACPI: \_SB_.LNKA: Enabled at IRQ 10
[    1.147446][    T1] ACPI: \_SB_.LNKB: Enabled at IRQ 11
[    1.148705][    T1] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    1.149773][    T1] 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    1.152154][    T1] Non-volatile memory driver v1.3
[    1.153004][    T1] Linux agpgart interface v0.103
[    1.154155][    T1] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    1.156282][    T1] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.157224][    T1] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.158262][    T1] mousedev: PS/2 mouse device common for all mice
[    1.159356][    T1] rtc_cmos 00:05: RTC can wake from S4
[    1.160760][   T38] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    1.162419][    T1] rtc_cmos 00:05: registered as rtc0
[    1.163334][    T1] rtc_cmos 00:05: alarms up to one day, y3k, 242 bytes nvram
[    1.164593][    T1] intel_pstate: CPU model not supported
[    1.165975][   T38] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input3
[    1.167727][   T38] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input2
[    1.170990][    T1] ledtrig-cpu: registered to indicate activity on CPUs
[    1.172207][    T1] efifb: probing for efifb
[    1.172955][    T1] efifb: framebuffer at 0xc0000000, using 4000k, total 4000k
[    1.174139][    T1] efifb: mode is 1280x800x32, linelength=5120, pages=1
[    1.175248][    T1] efifb: scrolling: redraw
[    1.175951][    T1] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[    1.178716][    T1] Console: switching to colour frame buffer device 160x50
[    1.180518][    T1] fb0: EFI VGA frame buffer device
[    1.181368][    T1] hid: raw HID events driver (C) Jiri Kosina
[    1.182385][    T1] drop_monitor: Initializing network drop monitor service
[    1.195677][    T1] NET: Registered PF_INET6 protocol family
[    3.512951][   T26] Freeing initrd memory: 92236K
[    3.517716][    T1] Segment Routing with IPv6
[    3.518421][    T1] RPL Segment Routing with IPv6
[    3.519492][    T1] IPI shorthand broadcast: enabled
[    3.520369][    T1] sched_clock: Marking stable (3352809952, 166608785)->(3527364002, -7945265)
[    3.522051][    T1] registered taskstats version 1
[    3.522944][    T1] Loading compiled-in X.509 certificates
[    3.523823][    T1] Loaded X.509 cert 'SUSE Linux Enterprise Secure Boot Signkey: a746b64b6cb71f13385638055f46162bac632acd'
[    3.525502][    T1] zswap: loaded using pool lzo/zbud
[    3.526396][    T1] page_owner is disabled
[    3.527232][    T1] Key type ._fscrypt registered
[    3.528047][    T1] Key type .fscrypt registered
[    3.528810][    T1] Key type fscrypt-provisioning registered
[    3.532939][    T1] Key type encrypted registered
[    3.533862][    T1] AppArmor: AppArmor sha1 policy hashing enabled
[    3.535091][    T1] ima: No TPM chip found, activating TPM-bypass!
[    3.536149][    T1] Loading compiled-in module X.509 certificates
[    3.537187][    T1] Loaded X.509 cert 'SUSE Linux Enterprise Secure Boot Signkey: a746b64b6cb71f13385638055f46162bac632acd'
[    3.539054][    T1] ima: Allocated hash algorithm: sha256
[    3.539988][    T1] ima: No architecture policies found
[    3.540877][    T1] evm: Initialising EVM extended attributes:
[    3.542200][    T1] evm: security.selinux
[    3.543188][    T1] evm: security.SMACK64 (disabled)
[    3.544303][    T1] evm: security.SMACK64EXEC (disabled)
[    3.545448][    T1] evm: security.SMACK64TRANSMUTE (disabled)
[    3.546769][    T1] evm: security.SMACK64MMAP (disabled)
[    3.547945][    T1] evm: security.apparmor
[    3.548908][    T1] evm: security.ima
[    3.549875][    T1] evm: security.capability
[    3.550810][    T1] evm: HMAC attrs: 0x1
[    3.552010][    T1] PM:   Magic number: 1:491:259
[    3.553255][    T1] RAS: Correctable Errors collector initialized.
[    3.554491][    T1] clk: Disabling unused clocks
[    3.557475][    T1] Freeing unused decrypted memory: 2028K
[    3.560221][    T1] Freeing unused kernel image (initmem) memory: 2884K
[    3.575077][    T1] Write protecting the kernel read-only data: 24576k
[    3.577368][    T1] Freeing unused kernel image (rodata/data gap) memory: 828K
[    3.579179][    T1] Run /init as init process
[    3.627110][    T1] systemd[1]: systemd 249.17+suse.228.gcba4725678 running in system mode (+PAM +AUDIT +SELINUX +APPARMOR -IMA -SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 +PWQUALITY +P11KIT +QRENCODE +TPM2 +BZIP2 +LZ4 +XZ +ZLIB +ZSTD -XKBCOMMON +UTMP +SYSVINIT default-hierarchy=hybrid)
[    3.632647][    T1] systemd[1]: Detected virtualization kvm.
[    3.633677][    T1] systemd[1]: Detected architecture x86-64.
[    3.634741][    T1] systemd[1]: Running in initial RAM disk.

Welcome to SUSE Linux Enterprise Micro for Rancher 5.5 dracut-055+suse.396.g701c6212-150500.3.29.2 (Initramfs)!

[    3.670309][    T1] systemd[1]: No hostname configured, using default hostname.
[    3.672503][    T1] systemd[1]: Hostname set to <localhost>.
[    3.674099][    T1] systemd[1]: Initializing machine ID from random generator.
[    3.743348][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-initramfs.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[    3.764351][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-rootfs.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[    3.768505][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-immutable-rootfs.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[    3.774209][    T1] systemd[1]: Queued start job for default target Initrd Default Target.
[    3.779369][    T1] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[  OK  ] Started Dispatch Password …ts to Console Directory Watch.
[    3.782463][    T1] systemd[1]: Reached target Local Encrypted Volumes.
[  OK  ] Reached target Local Encrypted Volumes.
[    3.784963][    T1] systemd[1]: Reached target Initrd Root Device.
[  OK  ] Reached target Initrd Root Device.
[    3.787219][    T1] systemd[1]: Reached target Initrd /usr File System.
[  OK  ] Reached target Initrd /usr File System.
[    3.789627][    T1] systemd[1]: Reached target Local File Systems.
[  OK  ] Reached target Local File Systems.
[    3.791990][    T1] systemd[1]: Reached target Path Units.
[  OK  ] Reached target Path Units.
[    3.794018][    T1] systemd[1]: Reached target Slice Units.
[  OK  ] Reached target Slice Units.
[    3.796045][    T1] systemd[1]: Reached target Swaps.
[  OK  ] Reached target Swaps.
[    3.797891][    T1] systemd[1]: Reached target Timer Units.
[  OK  ] Reached target Timer Units.
[    3.800030][    T1] systemd[1]: Listening on Open-iSCSI iscsid Socket.
[  OK  ] Listening on Open-iSCSI iscsid Socket.
[    3.802464][    T1] systemd[1]: Listening on Journal Socket (/dev/log).
[  OK  ] Listening on Journal Socket (/dev/log).
[    3.804975][    T1] systemd[1]: Listening on Journal Socket.
[  OK  ] Listening on Journal Socket.
[    3.807095][    T1] systemd[1]: Listening on udev Control Socket.
[  OK  ] Listening on udev Control Socket.
[    3.809381][    T1] systemd[1]: Listening on udev Kernel Socket.
[  OK  ] Listening on udev Kernel Socket.
[    3.811614][    T1] systemd[1]: Reached target Socket Units.
[  OK  ] Reached target Socket Units.
[    3.814378][    T1] systemd[1]: Started Entropy Daemon based on the HAVEGE algorithm.
[  OK  ] Started Entropy Daemon based on the HAVEGE algorithm.
[    3.817851][    T1] systemd[1]: Starting Create List of Static Device Nodes...
         Starting Create List of Static Device Nodes...
[    3.820987][    T1] systemd[1]: Starting Device-Mapper Multipath Device Controller...
         Starting Device-Mapper Multipath Device Controller...
[    3.826079][    T1] systemd[1]: Starting Journal Service...
         Starting Journal Service...
[    3.828780][    T1] systemd[1]: Starting Load Kernel Modules...
         Starting Load Kernel Modules...
[    3.831506][    T1] systemd[1]: Starting Setup Virtual Console...
         Starting Setup Virtual Console...
[    3.834247][    T1] systemd[1]: Finished Create List of Static Device Nodes.
[  OK  ] Finished Create List of Static Device Nodes.
[    3.843759][    T1] systemd[1]: Starting Create Static Device Nodes in /dev...
         Starting Create Static Device Nodes in /dev...
[    3.853517][  T211] SCSI subsystem initialized
[    3.859045][    T1] systemd[1]: Finished Setup Virtual Console.
[  OK  ] Finished Setup Virtual Console.
[    3.864452][    T1] systemd[1]: Condition check resulted in dracut ask for additional cmdline parameters being skipped.
[    3.869620][  T211] device-mapper: uevent: version 1.0.3
[    3.870567][  T211] device-mapper: ioctl: 4.47.0-ioctl (2022-07-28) initialised: dm-devel@redhat.com
[    3.871009][  T213] alua: device handler registered
[    3.873143][    T1] systemd[1]: Starting dracut cmdline hook...
         Starting dracut cmdline hook...
[    3.876036][  T213] emc: device handler registered
[    3.877594][  T213] rdac: device handler registered
[    3.883190][    T1] systemd[1]: Started Journal Service.
[  OK  ] Started Journal Service.
[  OK  ] Finished Create Static Device Nodes in /dev.
         Starting Create Volatile Files and Directories...
[    3.894087][  T213] NET: Registered PF_VSOCK protocol family
[  OK  ] Finished Create Volatile Files and Directories.
[    3.904333][  T213] Guest personality initialized and is inactive
[    3.906693][  T213] VMCI host device registered (name=vmci, major=10, minor=123)
[    3.908301][  T213] Initialized host personality
[  OK  ] Finished Load Kernel Modules.
         Starting Apply Kernel Variables...
[  OK  ] Finished Apply Kernel Variables.
[  OK  ] Started Device-Mapper Multipath Device Controller.
[    4.018949][  T372] Loading iSCSI transport class v2.0-870.
[    4.029275][  T372] iscsi: registered transport (tcp)
[    4.043097][  T375] iscsi: registered transport (qla4xxx)
[    4.044611][  T375] QLogic iSCSI HBA Driver
[    4.051526][  T375] libcxgbi:libcxgbi_init_module: Chelsio iSCSI driver library libcxgbi v0.9.1-ko (Apr. 2015)
[    4.064235][  T375] Chelsio T3 iSCSI Driver cxgb3i v2.0.1-ko (Apr. 2015)
[    4.065629][  T375] iscsi: registered transport (cxgb3i)
[    4.096213][  T375] Chelsio T4-T6 iSCSI Driver cxgb4i v0.9.5-ko (Apr. 2015)
[    4.097792][  T375] iscsi: registered transport (cxgb4i)
[    4.098919][  T375] cxgb4i:cxgb4i_init_module: cxgb4i dcb enabled.
[    4.105628][  T375] cnic: QLogic cnicDriver v2.5.22 (July 20, 2015)
[    4.109594][  T375] QLogic NetXtreme II iSCSI Driver bnx2i v2.7.10.1 (Jul 16, 2014)
[    4.111290][  T375] iscsi: registered transport (bnx2i)
[    4.116709][  T375] iscsi: registered transport (be2iscsi)
[    4.118025][  T375] In beiscsi_module_init, tt=000000005947c1eb
[  OK  ] Finished dracut cmdline hook.
         Starting dracut pre-udev hook...
[    4.245403][  T476] RPC: Registered named UNIX socket transport module.
[    4.246745][  T476] RPC: Registered udp transport module.
[    4.247806][  T476] RPC: Registered tcp transport module.
[    4.248751][  T476] RPC: Registered tcp NFSv4.1 backchannel transport module.
[  OK  ] Finished dracut pre-udev hook.
         Starting Rule-based Manage…for Device Events and Files...
[  OK  ] Started Rule-based Manager for Device Events and Files.
         Starting dracut pre-trigger hook...
[  OK  ] Finished dracut pre-trigger hook.
         Starting Coldplug All udev Devices...
[    4.432613][  T573] Floppy drive(s): fd0 is 2.88M AMI BIOS
[  OK  ] Finished Coldplug All udev Devices.
[  OK  ] Reached target System Initialization.
[  OK  ] Reached target Basic System.
         Starting dracut initqueue hook...
[    4.445765][  T577] virtio_blk virtio2: 2/0/0 default/read/poll queues
[    4.447863][  T577] virtio_blk virtio2: [vda] 524288000 512-byte logical blocks (268 GB/250 GiB)
[    4.452145][  T577] virtio_blk virtio3: 2/0/0 default/read/poll queues
[    4.452705][  T573] FDC 0 is a S82078B
[    4.454525][  T577] virtio_blk virtio3: [vdb] 14113024 512-byte logical blocks (7.23 GB/6.73 GiB)
[    4.466575][  T577]  vdb: vdb1 vdb2
[    4.485657][  T586] cryptd: max_cpu_qlen set to 1000
[    4.514220][  T575] virtio_net virtio0 ens3: renamed from eth0
[    4.522400][  T586] AVX2 version of gcm_enc/dec engaged.
[    4.523847][  T586] AES CTR mode by8 optimization enabled
[    4.535217][  T579] virtio_net virtio1 ens4: renamed from eth1
[    4.540001][  T580] scsi host0: ata_piix
[    4.542174][  T580] scsi host1: ata_piix
[    4.543241][  T580] ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0xc140 irq 14
[    4.543244][  T580] ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0xc148 irq 15
[    4.703266][  T622] ata2: found unknown device (class 0)
[    4.705034][  T622] ata2.00: ATAPI: QEMU DVD-ROM, 2.5+, max UDMA/100
[    4.707400][   T26] scsi 1:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM     2.5+ PQ: 0 ANSI: 5
[    4.741137][   T26] scsi 1:0:0:0: Attached scsi generic sg0 type 5
[    4.821940][  T572] sr 1:0:0:0: [sr0] scsi3-mmc drive: 4x/4x cd/rw xa/form2 tray
[    4.828883][  T572] cdrom: Uniform CD-ROM driver Revision: 3.20
[    5.483116][   T38] IPv6: ADDRCONF(NETDEV_CHANGE): ens3: link becomes ready
[    6.449654] dracut-initqueue[741]: wicked: ens3: Request to acquire DHCPv4 lease with UUID c9ea6968-2a53-0c00-e502-000001000000
[    6.635981][  T764] NET: Registered PF_PACKET protocol family
[    8.961741] dracut-initqueue[741]: wicked: ens3: Committed DHCPv4 lease with address 10.0.2.15 (lease time 86398, renew in 43198 sec, rebind in 75598 sec)
[    9.179480] dracut-initqueue[812]:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
[    9.187343] dracut-initqueue[812]:                                  Dload  Upload   Total   Spent    Left  Speed
100  790M  100  790M    0     0  87.2M      0  0:00:09  0:00:09 --:--:-- 84.0M
[   18.492187][  T860] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[   18.554418][  T869] loop: module loaded
[   18.562820][  T882] loop0: detected capacity change from 0 to 1618840
[  OK  ] Finished dracut initqueue hook.
[  OK  ] Reached target Preparation for Remote File Systems.
[  OK  ] Reached target Remote Encrypted Volumes.
[  OK  ] Reached target Remote File Systems.
         Starting dracut pre-mount hook...
[  OK  ] Finished dracut pre-mount hook.
         Mounting /sysroot...
[  OK  ] Mounted /sysroot.
[  OK  ] Reached target Initrd Root File System.
         Starting Elemental system early rootfs setup...
         Starting Reload Configuration from the Real Root...
         Stopping Device-Mapper Multipath Device Controller...
[  OK  ] Finished Reload Configuration from the Real Root.[   18.919009][   T26] I/O error, dev fd0, sector 0 op 0x0:(READ) flags 0x0 phys_seg 1 prio class 0

[   18.920644][   T26] floppy: error 10 while reading block 0
[   18.921882][   T26] floppy0: disk absent or changed during operation
[   18.923045][   T26] I/O error, dev fd0, sector 0 op 0x0:(READ) flags 0x80700 phys_seg 1 prio class 0
[   18.924817][   T26] floppy0: disk absent or changed during operation
[   18.926065][   T26] I/O error, dev fd0, sector 0 op 0x0:(READ) flags 0x0 phys_seg 1 prio class 0
[   18.927596][   T26] Buffer I/O error on dev fd0, logical block 0, async page read
[  OK  ] Stopped Device-Mapper Multipath Device Controller.
[   19.120734][  T104] floppy0: disk absent or changed during operation
[   19.125969][  T104] I/O error, dev fd0, sector 0 op 0x0:(READ) flags 0x80700 phys_seg 1 prio class 0
[   19.133651][  T104] floppy0: disk absent or changed during operation
[   19.138841][  T104] I/O error, dev fd0, sector 0 op 0x0:(READ) flags 0x0 phys_seg 1 prio class 0
[   19.145547][  T104] Buffer I/O error on dev fd0, logical block 0, async page read
[  OK  ] Finished Elemental system early rootfs setup.
         Starting Elemental system immutable rootfs mounts...
[  OK  ] Finished Elemental system immutable rootfs mounts.
[  OK  ] Reached target Initrd File Systems.
         Starting Elemental system …fs setup before switch root...
[   ***] A start job is running for Elementa…efore switch root (17s / no limit)
[   21.803134][   T26] I/O error, dev fd0, sector 0 op 0x0:(READ) flags 0x0 phys_seg 1 prio class 0
[  OK  ] Finished Elemental system …amfs setup before switch root.
[  OK  ] Reached target Initrd Default Target.
         Starting dracut pre-pivot and cleanup hook...
[  OK  ] Finished dracut pre-pivot and cleanup hook.
         Starting Cleaning Up and Shutting Down Daemons...
[  OK  ] Stopped target Remote Encrypted Volumes.
[  OK  ] Stopped target Timer Units.
[  OK  ] Stopped dracut pre-pivot and cleanup hook.
[  OK  ] Stopped target Initrd Default Target.
[  OK  ] Stopped target Basic System.
[  OK  ] Stopped target Initrd Root Device.
[  OK  ] Stopped target Initrd /usr File System.
[  OK  ] Stopped target Path Units.
[  OK  ] Stopped target Remote File Systems.
[  OK  ] Stopped target Preparation for Remote File Systems.
[  OK  ] Stopped target Slice Units.
[  OK  ] Stopped target Socket Units.
[  OK  ] Stopped target System Initialization.
[  OK  ] Stopped target Swaps.
[  OK  ] Closed Open-iSCSI iscsid Socket.
[  OK  ] Stopped dracut pre-mount hook.
[  OK  ] Stopped target Local Encrypted Volumes.
[  OK  ] Stopped Dispatch Password …ts to Console Directory Watch.
[  OK  ] Stopped dracut initqueue hook.
[  OK  ] Stopped Elemental system i…amfs setup before switch root.
         Starting Tell haveged about new root...
[  OK  ] Stopped Apply Kernel Variables.
[  OK  ] Stopped Load Kernel Modules.
[  OK  ] Stopped Create Volatile Files and Directories.
[  OK  ] Stopped target Local File Systems.
[  OK  ] Stopped Coldplug All udev Devices.
[  OK  ] Stopped dracut pre-trigger hook.
         Stopping Rule-based Manage…for Device Events and Files...
[  OK  ] Stopped Setup Virtual Console.
[  OK  ] Finished Cleaning Up and Shutting Down Daemons.
[  OK  ] Stopped Rule-based Manager for Device Events and Files.
[  OK  ] Finished Tell haveged about new root.
[  OK  ] Closed udev Control Socket.
[  OK  ] Closed udev Kernel Socket.
[  OK  ] Stopped dracut pre-udev hook.
[  OK  ] Stopped dracut cmdline hook.
         Starting Cleanup udev Database...
[  OK  ] Stopped Create Static Device Nodes in /dev.
[  OK  ] Stopped Create List of Static Device Nodes.
[  OK  ] Finished Cleanup udev Database.
[  OK  ] Reached target Switch Root.
         Starting Switch Root...
[   22.601824][  T212] systemd-journald[212]: Received SIGTERM from PID 1 (systemd).
[   22.837504][    T1] systemd[1]: systemd 249.17+suse.228.gcba4725678 running in system mode (+PAM +AUDIT +SELINUX +APPARMOR -IMA -SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 +PWQUALITY +P11KIT +QRENCODE +TPM2 +BZIP2 +LZ4 +XZ +ZLIB +ZSTD -XKBCOMMON +UTMP +SYSVINIT default-hierarchy=hybrid)
[   22.843501][    T1] systemd[1]: Detected virtualization kvm.
[   22.844709][    T1] systemd[1]: Detected architecture x86-64.

Welcome to Harvester v1.5.0!

[   22.910762][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-initramfs.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[   22.954681][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-reconcile.timer is marked executable. Please remove executable permission bits. Proceeding anyway.
[   22.958108][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-reconcile.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[   22.961509][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-network.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[   22.964931][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-boot.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[   22.970688][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-rootfs.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[   22.979741][    T1] systemd[1]: Configuration file /usr/lib/systemd/system/elemental-setup-fs.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[  OK  ] Stopped Entropy Daemon based on the HAVEGE algorithm.
[   23.022220][    T1] systemd[1]: initrd-switch-root.service: Deactivated successfully.
[   23.024207][    T1] systemd[1]: Stopped Switch Root.
[  OK  ] Stopped Switch Root.
[   23.026340][    T1] systemd[1]: systemd-journald.service: Scheduled restart job, restart counter is at 1.
[   23.028476][    T1] systemd[1]: Created slice Slice /system/getty.
[  OK  ] Created slice Slice /system/getty.
[   23.031069][    T1] systemd[1]: Created slice Slice /system/modprobe.
[  OK  ] Created slice Slice /system/modprobe.
[   23.033648][    T1] systemd[1]: Created slice Slice /system/serial-getty.
[  OK  ] Created slice Slice /system/serial-getty.
[   23.036309][    T1] systemd[1]: Created slice User and Session Slice.
[  OK  ] Created slice User and Session Slice.
[   23.038620][    T1] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[  OK  ] Started Dispatch Password …ts to Console Directory Watch.
[   23.041627][    T1] systemd[1]: Set up automount Arbitrary Executable File Formats File System Automount Point.
[  OK  ] Set up automount Arbitrary…s File System Automount Point.
[   23.044691][    T1] systemd[1]: Reached target Local Encrypted Volumes.
[  OK  ] Reached target Local Encrypted Volumes.
[   23.047004][    T1] systemd[1]: Stopped target Switch Root.
[  OK  ] Stopped target Switch Root.
[   23.049036][    T1] systemd[1]: Stopped target Initrd File Systems.
[  OK  ] Stopped target Initrd File Systems.
[   23.051274][    T1] systemd[1]: Reached target Slice Units.
[  OK  ] Reached target Slice Units.
[   23.053234][    T1] systemd[1]: Reached target Swaps.
[  OK  ] Reached target Swaps.
[   23.055072][    T1] systemd[1]: Reached target Local Verity Protected Volumes.
[  OK  ] Reached target Local Verity Protected Volumes.
[   23.057561][    T1] systemd[1]: Listening on Device-mapper event daemon FIFOs.
[  OK  ] Listening on Device-mapper event daemon FIFOs.
[   23.061181][    T1] systemd[1]: Listening on LVM2 poll daemon socket.
[  OK  ] Listening on LVM2 poll daemon socket.
[   23.063375][    T1] systemd[1]: Listening on initctl Compatibility Named Pipe.
[  OK  ] Listening on initctl Compatibility Named Pipe.
[   23.067296][    T1] systemd[1]: Listening on udev Control Socket.
[  OK  ] Listening on udev Control Socket.
[   23.069539][    T1] systemd[1]: Listening on udev Kernel Socket.
[  OK  ] Listening on udev Kernel Socket.
[   23.072257][    T1] systemd[1]: Mounting Huge Pages File System...
         Mounting Huge Pages File System...
[   23.074908][    T1] systemd[1]: Mounting POSIX Message Queue File System...
         Mounting POSIX Message Queue File System...
[   23.077717][    T1] systemd[1]: Mounting Kernel Debug File System...
         Mounting Kernel Debug File System...
[   23.080476][    T1] systemd[1]: Mounting Kernel Trace File System...
         Mounting Kernel Trace File System...
[   23.083272][    T1] systemd[1]: Mounting Temporary Directory /tmp...
         Mounting Temporary Directory /tmp...
[   23.085962][    T1] systemd[1]: Starting Load AppArmor profiles...
         Starting Load AppArmor profiles...
[   23.088024][    T1] systemd[1]: elemental-immutable-rootfs.service: Deactivated successfully.
[   23.089689][    T1] systemd[1]: Stopped elemental-immutable-rootfs.service.
[  OK  ] Stopped elemental-immutable-rootfs.service.
[   23.092152][    T1] systemd[1]: elemental-setup-rootfs.service: Deactivated successfully.
[   23.093786][    T1] systemd[1]: Stopped Elemental system early rootfs setup.
[  OK  ] Stopped Elemental system early rootfs setup.
[   23.096166][    T1] systemd[1]: Stopped target Initrd Root File System.
[  OK  ] Stopped target Initrd Root File System.
[   23.107568][    T1] systemd[1]: Starting Create List of Static Device Nodes...
         Starting Create List of Static Device Nodes...
[   23.110526][    T1] systemd[1]: Starting Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling...
         Starting Monitoring of LVM…meventd or progress polling...
[   23.116704][    T1] systemd[1]: Starting Load Kernel Module configfs...
         Starting Load Kernel Module configfs...
[   23.119429][    T1] systemd[1]: Starting Load Kernel Module drm...
         Starting Load Kernel Module drm...
[   23.122084][    T1] systemd[1]: Starting Load Kernel Module efi_pstore...
         Starting Load Kernel Module efi_pstore...
[   23.125677][    T1] systemd[1]: Starting Load Kernel Module fuse...
         Starting Load Kernel Module fuse...
[   23.127824][    T1] systemd[1]: Stopped Journal Service.
[  OK  ] Stopped Journal Service.
[   23.130755][    T1] systemd[1]: Starting Journal Service...
         Starting Journal Service...
[   23.193073][    T1] systemd[1]: Starting Load Kernel Modules...
         Starting Load Kernel Modules...
[   23.199825][    T1] systemd[1]: Starting Remount Root and Kernel File Systems...
         Starting Remount Root and Kernel File Systems...
[   23.203998][    T1] systemd[1]: Starting Coldplug All udev Devices...
         Starting Coldplug All udev Devices...
[   23.207101][    T1] systemd[1]: Mounted Huge Pages File System.
[  OK  ] Mounted Huge Pages File System.
[   23.209092][    T1] systemd[1]: Mounted POSIX Message Queue File System.
[  OK  ] Mounted POSIX Message Queue File System.
[   23.211596][    T1] systemd[1]: Mounted Kernel Debug File System.
[  OK  ] Mounted Kernel Debug File System.
[   23.213638][    T1] systemd[1]: Mounted Kernel Trace File System.
[  OK  ] Mounted Kernel Trace File System.
[   23.215652][    T1] systemd[1]: Mounted Temporary Directory /tmp.
[  OK  ] Mounted Temporary Directory /tmp.
[   23.217834][    T1] systemd[1]: Finished Create List of Static Device Nodes.
[  OK  ] Finished Create List of Static Device Nodes.
[   23.229843][    T1] systemd[1]: Finished Remount Root and Kernel File Systems.
[  OK  ] Finished Remount Root and Kernel File Systems.
[   23.232450][    T1] systemd[1]: Condition check resulted in One time configuration for iscsi.service being skipped.
[   23.234225][    T1] systemd[1]: Condition check resulted in First Boot Wizard being skipped.
[   23.263341][    T1] systemd[1]: Starting Rebuild Hardware Database...
         Starting Rebuild Hardware Database...
[   23.266113][    T1] systemd[1]: Starting Load/Save Random Seed...
         Starting Load/Save Random Seed...
[   23.272652][    T1] systemd[1]: Starting Create System Users...
         Starting Create System Users...
[   23.291274][    T1] systemd[1]: modprobe@efi_pstore.service: Deactivated successfully.
[   23.293032][    T1] systemd[1]: Finished Load Kernel Module efi_pstore.
[  OK  ] Finished Load Kernel Module efi_pstore.
[   23.295326][    T1] systemd[1]: Condition check resulted in Platform Persistent Storage Archival being skipped.
[   23.316790][    T1] systemd[1]: Started Journal Service.
[  OK  ] Started Journal Service.
         Starting Flush Journal to Persistent Storage...
[  OK  ] Finished Coldplug All udev Devices.
[   23.399421][ T1276] fuse: init (API version 7.34)
[  OK  ] Finished Load Kernel Module fuse.
         Mounting FUSE Control File System...
[  OK  ] Finished Load Kernel Module configfs.
         Mounting Kernel Configuration File System...
[  OK  ] Finished Load/Save Random Seed.
[   23.438666][ T1277] systemd-journald[1277]: Received client request to flush runtime journal.
[  OK  ] Mounted FUSE Control File System.
[  OK  ] Mounted Kernel Configuration File System.
[   23.481912][ T1274] ACPI: bus type drm_connector registered
[  OK  ] Finished Load Kernel Module drm.
[  OK  ] Finished Load Kernel Modules.
         Starting Apply Kernel Vari…0.55.100-default from /boot...
[  OK  ] Finished Flush Journal to Persistent Storage.
[  OK  ] Finished Apply Kernel Vari…500.55.100-default from /boot.
[  OK  ] Finished Load AppArmor profiles.
         Starting Apply Kernel Variables...
[  OK  ] Finished Create System Users.
         Starting Create Static Device Nodes in /dev...
[  OK  ] Finished Create Static Device Nodes in /dev.
[  OK  ] Finished Apply Kernel Variables.
[  OK  ] Finished Monitoring of LVM… dmeventd or progress polling.
[  OK  ] Finished Rebuild Hardware Database.
         Starting Rule-based Manage…for Device Events and Files...
[  OK  ] Started Rule-based Manager for Device Events and Files.
[  OK  ] Reached target Preparation for Local File Systems.
[  OK  ] Reached target Local File Systems.
         Starting Restore /run/initramfs on shutdown...
         Starting Elemental system after FS setup...
         Starting Create Volatile Files and Directories...
[  OK  ] Finished Restore /run/initramfs on shutdown.
[  OK  ] Finished Create Volatile Files and Directories.
         Starting Security Auditing Service...
         Starting Rebuild Journal Catalog...
         Starting Network Time Synchronization...
[  OK  ] Finished Elemental system after FS setup.
[   24.267850][ T1299] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input4
[   24.270316][ T1317] input: PC Speaker as /devices/platform/pcspkr/input/input5
[   24.283015][ T1299] ACPI: button: Power Button [PWRF]
[   24.300588][ T1315] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[  OK  ] Started Entropy Daemon based on the HAVEGE algorithm.
[   24.409710][ T1298] parport_pc 00:03: reported by Plug and Play ACPI
[   24.411047][ T1298] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[   24.529866][ T1313] Console: switching to colour dummy device 80x25
[   24.531203][ T1313] bochs-drm 0000:00:02.0: vgaarb: deactivate vga console
[   24.532281][ T1313] [drm] Found bochs VGA, ID 0xb0c5.
[   24.533008][ T1313] [drm] Framebuffer size 16384 kB @ 0xc0000000, mmio @ 0xc1084000.
[   24.535144][ T1313] [drm] Found EDID data blob.
[   24.543674][ T1313] [drm] Initialized bochs-drm 1.0.0 20130925 for 0000:00:02.0 on minor 0
[   24.545556][ T1313] fbcon: bochs-drmdrmfb (fb0) is primary device
[   24.569256][ T1313] Console: switching to colour frame buffer device 160x50
[   24.575635][ T1310] ppdev: user-space parallel port driver
[   24.783339][ T1313] bochs-drm 0000:00:02.0: [drm] fb0: bochs-drmdrmfb frame buffer device
[  OK  ] Finished Rebuild Journal Catalog.
         Starting Update is Completed...
[  OK  ] Started Network Time Synchronization.
[  OK  ] Reached target System Time Set.
[  OK  ] Reached target System Time Synchronized.
[  OK  ] Started Security Auditing Service.
[  OK  ] Finished Update is Completed.
         Starting Record System Boot/Shutdown in UTMP...
[  OK  ] Finished Record System Boot/Shutdown in UTMP.
[  OK  ] Reached target System Initialization.
[  OK  ] Started Watch for changes in CA certificates.
[  OK  ] Started Watch for changes in issue snippets.
[  OK  ] Started Watch for changes … smartmontools sysconfig file.
[  OK  ] Started Elemental setup reconciler.
[  OK  ] Started Discard unused blocks once a week.
[  OK  ] Started Daily rotation of log files.
[  OK  ] Started Daily Cleanup of Temporary Directories.
[  OK  ] Reached target Path Units.
[  OK  ] Reached target Timer Units.
[  OK  ] Listening on D-Bus System Message Bus Socket.
[  OK  ] Listening on Open-iSCSI iscsid Socket.
[  OK  ] Reached target Socket Units.
[  OK  ] Reached target Basic System.
         Starting auditd rules generation...
[  OK  ] Started D-Bus System Message Bus.
[  OK  ] Started Detect if the system suffers from bsc#1089761.
         Starting Elemental system configuration...
         Starting Generate issue file for login session...
         Starting Apply settings from /etc/sysconfig/keyboard...
         Starting User Login Management...
         Starting wicked AutoIPv4 supplicant service...
         Starting wicked DHCPv4 supplicant service...
         Starting wicked DHCPv6 supplicant service...
         Starting Elemental setup reconciler...
[  OK  ] Finished Generate issue file for login session.
[  OK  ] Finished Apply settings from /etc/sysconfig/keyboard.
[  OK  ] Finished auditd rules generation.
         Starting Load Kernel Module drm...
[  OK  ] Started User Login Management.
[  OK  ] Finished Load Kernel Module drm.
[  OK  ] Started wicked AutoIPv4 supplicant service.
[  OK  ] Started wicked DHCPv6 supplicant service.
[  OK  ] Started wicked DHCPv4 supplicant service.
         Starting wicked network management service daemon...
[  OK  ] Started wicked network management service daemon.
[  OK  ] Finished Elemental setup reconciler.
[  OK  ] Listening on Load/Save RF …itch Status /dev/rfkill Watch.
         Starting wicked network nanny service...
[  OK  ] Started wicked network nanny service.
         Starting wicked managed network interfaces...
[   25.921231][ T1533] No iBFT detected.
[  OK  ] Finished wicked managed network interfaces.
[  OK  ] Reached target Network.
[  OK  ] Reached target Network is Online.
[  OK  ] Started Command Scheduler.
         Starting Login and scanning of iSCSI devices...
         Starting Rancher Bootstrap...
         Starting OpenSSH Daemon...
         Starting Elemental setup after network...
[  OK  ] Finished Elemental system configuration.
[  OK  ] Finished Login and scanning of iSCSI devices.
[  OK  ] Reached target Remote File Systems.
         Starting Permit User Sessions...
[  OK  ] Finished Permit User Sessions.
[  OK  ] Started Getty on tty1.
[  OK  ] Started Serial Getty on ttyS0.
[  OK  ] Reached target Login Prompts.
[  OK  ] Finished Elemental setup after network.
[  OK  ] Started OpenSSH Daemon.
[  OK  ] Finished Rancher Bootstrap.
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.
         Starting Record Runlevel Change in UTMP...
[  OK  ] Finished Record Runlevel Change in UTMP.


Welcome to SUSE Linux Enterprise Micro for Rancher 5.5 (x86_64) - Kernel 5.14.21-150500.55.100-default (ttyS0).

ens3:
ens4:


node0 login: [ 1285.175013][ T2601] reboot: Power down
+ kill_tmp_http_server
++ ss -ltnp 'sport = :10080'
++ grep servefile
++ grep -P -o '(?<=,pid=)\d+(?=,)'
++ head -n 1
+ HTTP_SERVER_PID=1385547
+ kill -9 1385547
++ losetup --find --show --partscan /srv/repos/os_images/harvester1.5.0.dd
+ LOOP_DEV=/dev/loop2
bin/harvester1.5.0_step0_prepare_uefi_only_boot_image.sh: line 132: 1385547 Killed                  servefile -l -p 10080 "$RES_IMAGE".tmp > "$RES_IMAGE".tmp/http.log 2>&1
++ blkid -t LABEL=COS_OEM -o device /dev/loop2p1 /dev/loop2p2 /dev/loop2p3 /dev/loop2p4 /dev/loop2p5 /dev/loop2p6
+ COS_OEM_PART_DEV=/dev/loop2p2
+ mkdir -p /srv/repos/os_images/harvester1.5.0.dd.tmp/part-COS_OEM.mount
+ mount -o ro /dev/loop2p2 /srv/repos/os_images/harvester1.5.0.dd.tmp/part-COS_OEM.mount
+ cat /srv/repos/os_images/harvester1.5.0.dd.tmp/part-COS_OEM.mount/install/console.log
time="2025-07-06T03:17:53Z" level=info msg="my tty is /dev/tty1"
time="2025-07-06T03:17:53Z" level=info msg="Start automatic installation..."
time="2025-07-06T03:17:53Z" level=info msg="Local config: {SchemeVersion:0 ServerURL: Token: OS:{AfterInstallChrootCommands:[] SSHAuthorizedKeys:[] WriteFiles:[] Hostname: Modules:[kvm vhost_net] Sysctls:map[] NTPServers:[] DNSNameservers:[] Wifi:[] Password: Environment:map[] Labels:map[] SSHD:{SFTP:false} PersistentStatePaths:[] ExternalStorage:{Enabled:false MultiPathConfig:[]} AdditionalKernelArguments:} Install:{Automatic:true SkipChecks:true Mode: ManagementInterface:{Interfaces:[] Method: IP: SubnetMask: Gateway: DefaultRoute:false BondOptions:map[] MTU:0 VlanID:0} Vip: VipHwAddr: VipMode: ClusterDNS: ClusterPodCIDR: ClusterServiceCIDR: ForceEFI:false Device: ConfigURL:http://10.0.2.2:10080/harvester_install_config.yml Silent:false ISOURL: PowerOff:false NoFormat:false Debug:false TTY: ForceGPT:false Role: WithNetImages:false WipeAllDisks:false WipeDisksList:[] ForceMBR:false DataDisk: Webhooks:[] Addons:map[] Harvester:{StorageClass:{ReplicaCount:0} Longhorn:{DefaultSettings:{GuaranteedEngineManagerCPU:<nil> GuaranteedReplicaManagerCPU:<nil> GuaranteedInstanceManagerCPU:<nil>}} EnableGoCoverDir:false} RawDiskImagePath: PersistentPartitionSize:} RuntimeVersion: RancherVersion: HarvesterChartVersion: MonitoringChartVersion: SystemSettings:map[] LoggingChartVersion:}"
time="2025-07-06T03:17:53Z" level=info msg="Remote config: {SchemeVersion:1 ServerURL: Token:*** OS:{AfterInstallChrootCommands:[] SSHAuthorizedKeys:[] WriteFiles:[] Hostname:node0 Modules:[] Sysctls:map[] NTPServers:[] DNSNameservers:[] Wifi:[] Password:*** Environment:map[] Labels:map[] SSHD:{SFTP:false} PersistentStatePaths:[] ExternalStorage:{Enabled:false MultiPathConfig:[]} AdditionalKernelArguments:} Install:{Automatic:false SkipChecks:false Mode:create ManagementInterface:{Interfaces:[{Name: HwAddr:52:54:00:ec:0e:0b}] Method:dhcp IP: SubnetMask: Gateway: DefaultRoute:false BondOptions:map[] MTU:0 VlanID:0} Vip: VipHwAddr:52:54:00:ec:0e:0b VipMode:dhcp ClusterDNS: ClusterPodCIDR: ClusterServiceCIDR: ForceEFI:true Device:/dev/vda ConfigURL: Silent:false ISOURL:/dev/vdb PowerOff:true NoFormat:false Debug:true TTY:ttyS0 ForceGPT:false Role: WithNetImages:false WipeAllDisks:false WipeDisksList:[] ForceMBR:false DataDisk: Webhooks:[] Addons:map[] Harvester:{StorageClass:{ReplicaCount:0} Longhorn:{DefaultSettings:{GuaranteedEngineManagerCPU:<nil> GuaranteedReplicaManagerCPU:<nil> GuaranteedInstanceManagerCPU:<nil>}} EnableGoCoverDir:false} RawDiskImagePath: PersistentPartitionSize:} RuntimeVersion: RancherVersion: HarvesterChartVersion: MonitoringChartVersion: SystemSettings:map[] LoggingChartVersion:}"
time="2025-07-06T03:17:53Z" level=info msg="Local config (merged): {SchemeVersion:1 ServerURL: Token:*** OS:{AfterInstallChrootCommands:[] SSHAuthorizedKeys:[] WriteFiles:[] Hostname:node0 Modules:[kvm vhost_net] Sysctls:map[] NTPServers:[] DNSNameservers:[] Wifi:[] Password:*** Environment:map[] Labels:map[] SSHD:{SFTP:false} PersistentStatePaths:[] ExternalStorage:{Enabled:false MultiPathConfig:[]} AdditionalKernelArguments:} Install:{Automatic:true SkipChecks:true Mode:create ManagementInterface:{Interfaces:[{Name: HwAddr:52:54:00:ec:0e:0b}] Method:dhcp IP: SubnetMask: Gateway: DefaultRoute:false BondOptions:map[] MTU:0 VlanID:0} Vip: VipHwAddr:52:54:00:ec:0e:0b VipMode:dhcp ClusterDNS: ClusterPodCIDR: ClusterServiceCIDR: ForceEFI:true Device:/dev/vda ConfigURL:http://10.0.2.2:10080/harvester_install_config.yml Silent:false ISOURL:/dev/vdb PowerOff:true NoFormat:false Debug:true TTY:ttyS0 ForceGPT:false Role: WithNetImages:false WipeAllDisks:false WipeDisksList:[] ForceMBR:false DataDisk: Webhooks:[] Addons:map[] Harvester:{StorageClass:{ReplicaCount:0} Longhorn:{DefaultSettings:{GuaranteedEngineManagerCPU:<nil> GuaranteedReplicaManagerCPU:<nil> GuaranteedInstanceManagerCPU:<nil>}} EnableGoCoverDir:false} RawDiskImagePath: PersistentPartitionSize:} RuntimeVersion: RancherVersion: HarvesterChartVersion: MonitoringChartVersion: SystemSettings:map[] LoggingChartVersion:}"
time="2025-07-06T03:17:53Z" level=info msg="Adding default NIC bonding options for \"mgmt-bo\""
time="2025-07-06T03:17:57Z" level=info msg="&{DHCPv4(xid=0xf6217c44 hwaddr=1a:e2:c0:9c:82:46 msg_type=OFFER, your_ip=10.0.2.16, server_ip=10.0.2.2) DHCPv4(xid=0xf6217c44 hwaddr=1a:e2:c0:9c:82:46 msg_type=ACK, your_ip=10.0.2.16, server_ip=10.0.2.2) 2025-07-06 03:17:57.363112248 +0000 UTC m=+4.104810044}"
time="2025-07-06T03:17:57Z" level=error msg="unable to determine NIC speed from /sys/class/net/ens3/speed (got -1)"
time="2025-07-06T03:17:57Z" level=warning msg="Only 2 CPU cores detected. Harvester requires at least 8 cores for testing and 16 for production use."
time="2025-07-06T03:17:57Z" level=warning msg="Only 4GiB RAM detected. Harvester requires at least 32GiB for testing and 64GiB for production use."
time="2025-07-06T03:17:57Z" level=warning msg="System is virtualized (kvm) which is not supported in production."
time="2025-07-06T03:17:57Z" level=info msg="Installation will proceed (harvester.install.skipchecks = true)"
time="2025-07-06T03:17:57Z" level=info msg="handle webhooks for event STARTED"
time="2025-07-06T03:17:57Z" level=info msg="Adding default NIC bonding options for \"mgmt-bo\""
time="2025-07-06T03:17:57Z" level=info msg="Content of /tmp/cos.2670445099: name: Harvester Configuration\nstages:\n    initramfs:\n        - commands:\n            - modprobe kvm\n            - modprobe vhost_net\n            - rm -f /var/lib/kubelet/cpu_ma ... skipped ...
time="2025-07-06T03:17:57Z" level=info msg="Calculated COS_PERSISTENT partition size: 153600 MiB"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: Checking ISO URL.."
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: Deactivating block devices:"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Starting elemental version 1.1.6 on commit e9f70ce5 "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:17:57Z] Reading configuration from '/tmp/elemental'  "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Full config loaded: &v1.RunConfig{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Reboot: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   PowerOff: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   EjectCD: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Config: v1.Config{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Logger: &v1.logrusWrapper{ // p0"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Logger: &logrus.Logger{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         Out: &os.File{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         Hooks: logrus.LevelHooks{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         Formatter: &logrus.TextFormatter{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           ForceColors: true,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           DisableColors: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           ForceQuote: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           DisableQuote: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           EnvironmentOverrideColors: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           DisableTimestamp: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           FullTimestamp: true,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           TimestampFormat: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           DisableSorting: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           SortingFunc: ,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           DisableLevelTruncation: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           PadLevelText: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           QuoteEmptyFields: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           FieldMap: logrus.FieldMap(nil),"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:           CallerPrettyfier: ,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         ReportCaller: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         Level: 5,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         ExitFunc: os.Exit,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         BufferPool: nil,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Fs: &vfs.osfs{}, // p1"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Mounter: &mount.Mounter{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Runner: &v1.RealRunner{ // p2"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Logger: p0,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Syscall: &v1.RealSyscall{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     CloudInitRunner: &cloudinit.YipCloudInitRunner{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     ImageExtractor: v1.OCIImageExtractor{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Client: &http.Client{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Platform: &v1.Platform{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       OS: \"linux\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Arch: \"x86_64\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       GolangArch: \"amd64\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Cosign: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Verify: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     CosignPubKey: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     LocalImage: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Arch: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     SquashFsCompressionConfig: []string{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       \"-comp\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       \"xz\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       \"-Xbcj\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       \"x86\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     SquashFsNoCompression: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     CloudInitPaths: []string{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       \"/system/oem\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       \"/oem/\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       \"/usr/local/cloud-config/\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Strict: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: } "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Loaded install spec: &v1.InstallSpec{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Target: \"/dev/vda\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Firmware: \"efi\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   PartTable: \"gpt\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Partitions: v1.ElementalPartitions{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     BIOS: nil,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     EFI: &v1.Partition{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Name: \"efi\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FilesystemLabel: \"COS_GRUB\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Size: 64,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FS: \"vfat\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Flags: []string{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:         \"esp\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       MountPoint: \"/run/cos/efi\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Path: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Disk: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     OEM: &v1.Partition{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Name: \"oem\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FilesystemLabel: \"COS_OEM\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Size: 50,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FS: \"ext4\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Flags: []string{}, // p0"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       MountPoint: \"/run/cos/oem\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Path: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Disk: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Recovery: &v1.Partition{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Name: \"recovery\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FilesystemLabel: \"COS_RECOVERY\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Size: 8192,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FS: \"ext4\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Flags: p0,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       MountPoint: \"/run/cos/recovery\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Path: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Disk: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     State: &v1.Partition{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Name: \"state\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FilesystemLabel: \"COS_STATE\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Size: 15360,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FS: \"ext4\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Flags: p0,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       MountPoint: \"/run/cos/state\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Path: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Disk: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Persistent: &v1.Partition{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Name: \"persistent\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FilesystemLabel: \"COS_PERSISTENT\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Size: 153600,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FS: \"ext4\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Flags: p0,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       MountPoint: \"/run/cos/persistent\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Path: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Disk: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   ExtraPartitions: v1.PartitionList{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     &v1.Partition{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Name: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FilesystemLabel: \"HARV_LH_DEFAULT\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Size: 0,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       FS: \"ext4\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Flags: nil,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       MountPoint: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Path: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:       Disk: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   NoFormat: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Force: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   CloudInit: []string{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     \"/tmp/cos.2670445099\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Iso: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   GrubDefEntry: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Active: v1.Image{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     File: \"/run/cos/state/cOS/active.img\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Label: \"COS_ACTIVE\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Size: 3072,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     FS: \"ext2\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Source: &v1.ImageSource{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     MountPoint: \"/run/cos/active\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     LoopDevice: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Recovery: v1.Image{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     File: \"/run/cos/recovery/cOS/recovery.img\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Label: \"COS_SYSTEM\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Size: 0,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     FS: \"ext2\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Source: &v1.ImageSource{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     MountPoint: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     LoopDevice: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   Passive: v1.Image{"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     File: \"/run/cos/state/cOS/passive.img\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Label: \"COS_PASSIVE\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Size: 0,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     FS: \"ext2\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     Source: &v1.ImageSource{},"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     MountPoint: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:     LoopDevice: \"\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   },"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   GrubConf: \"/etc/cos/grub.cfg\","
time="2025-07-06T03:17:57Z" level=info msg="[stdout]:   DisableBootEntry: false,"
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: } "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:17:57Z] Install called                               "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Running cmd: 'blkdeactivate --lvmoptions retry,wholevg --dmoptions force,retry --errors' "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] blkdeactivate command output: Deactivating block devices: "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:17:57Z] Partitioning device...                       "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Running cmd: 'parted --script --machine -- /dev/vda unit s mklabel gpt' "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Running cmd: 'partx -u /dev/vda'             "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] 'partx' command reported an error: exit status 1 "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] 'partx' command output: partx: specified range <1:0> does not make sense "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Running cmd: 'parted --script --machine -- /dev/vda unit s print' "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Adding partition efi                         "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Running cmd: 'parted --script --machine -- /dev/vda unit s mkpart efi fat32 2048 133119 set 1 esp on' "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Running cmd: 'partx -u /dev/vda'             "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] partitioner output:                          "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Running cmd: 'parted --script --machine -- /dev/vda unit s print' "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Trying to find the partition device 1 of device /dev/vda (try number 1) "
time="2025-07-06T03:17:57Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:57Z] Running cmd: 'udevadm settle'                "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Formatting partition with label COS_GRUB     "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'mkfs.vfat -n COS_GRUB /dev/vda1' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Adding partition oem                         "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'parted --script --machine -- /dev/vda unit s mkpart oem ext4 133120 235519' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'partx -u /dev/vda'             "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] partitioner output:                          "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'parted --script --machine -- /dev/vda unit s print' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Trying to find the partition device 2 of device /dev/vda (try number 1) "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'udevadm settle'                "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Formatting partition with label COS_OEM      "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'mkfs.ext4 -L COS_OEM /dev/vda2' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Adding partition recovery                    "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'parted --script --machine -- /dev/vda unit s mkpart recovery ext4 235520 17012735' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'partx -u /dev/vda'             "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] partitioner output:                          "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'parted --script --machine -- /dev/vda unit s print' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Trying to find the partition device 3 of device /dev/vda (try number 1) "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'udevadm settle'                "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Formatting partition with label COS_RECOVERY "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'mkfs.ext4 -L COS_RECOVERY /dev/vda3' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Adding partition state                       "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'parted --script --machine -- /dev/vda unit s mkpart state ext4 17012736 48470015' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'partx -u /dev/vda'             "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] partitioner output:                          "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'parted --script --machine -- /dev/vda unit s print' "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Trying to find the partition device 4 of device /dev/vda (try number 1) "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'udevadm settle'                "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Formatting partition with label COS_STATE    "
time="2025-07-06T03:17:58Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:58Z] Running cmd: 'mkfs.ext4 -L COS_STATE /dev/vda4' "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Adding partition persistent                  "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'parted --script --machine -- /dev/vda unit s mkpart persistent ext4 48470016 363042815' "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'partx -u /dev/vda'             "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] partitioner output:                          "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'parted --script --machine -- /dev/vda unit s print' "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Trying to find the partition device 5 of device /dev/vda (try number 1) "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'udevadm settle'                "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Formatting partition with label COS_PERSISTENT "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'mkfs.ext4 -L COS_PERSISTENT /dev/vda5' "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Adding partition                             "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'parted --script --machine -- /dev/vda unit s mkpart part6 ext4 363042816 100%' "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'partx -u /dev/vda'             "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] partitioner output:                          "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'parted --script --machine -- /dev/vda unit s print' "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Trying to find the partition device 6 of device /dev/vda (try number 1) "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'udevadm settle'                "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Formatting partition with label HARV_LH_DEFAULT "
time="2025-07-06T03:17:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:17:59Z] Running cmd: 'mkfs.ext4 -L HARV_LH_DEFAULT /dev/vda6' "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:00Z] Mounting disk partitions                     "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:00Z] Mounting partition COS_GRUB                  "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:00Z] Mounting partition COS_OEM                   "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:00Z] Mounting partition COS_PERSISTENT            "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:00Z] Mounting partition COS_RECOVERY              "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:00Z] Mounting partition COS_STATE                 "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:00Z] Running before-install hook                  "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:00Z] Preparing root tree for image: /run/cos/state/cOS/active.img "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:00Z] Copying /run/rootfsbase source...            "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:00Z] Starting rsync...                            "
time="2025-07-06T03:18:00Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:00Z] Running cmd: 'rsync --progress --partial --human-readable --archive --xattrs --acls --exclude=/mnt --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/tmp --exclude=/host --exclude=/run /run/rootfsbase/ /run/cos/workingtree/' "
time="2025-07-06T03:18:05Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:05Z] Syncing data...                              "
time="2025-07-06T03:18:10Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:10Z] Syncing data...                              "
time="2025-07-06T03:18:15Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:15Z] Syncing data...                              "
time="2025-07-06T03:18:20Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:20Z] Syncing data...                              "
time="2025-07-06T03:18:25Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:25Z] Syncing data...                              "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:29Z] Finished syncing                             "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:29Z] Finished copying /run/rootfsbase into /run/cos/workingtree "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:29Z] Finished copying cloud config file [/tmp/cos.2670445099] to /run/cos/oem/90_custom.yaml "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:29Z] Generating grub files for efi on /run/cos/efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/grub2/x86_64-efi/loopback.mod to /run/cos/state/grub2/x86_64-efi/loopback.mod "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/grub2/x86_64-efi/squash4.mod to /run/cos/state/grub2/x86_64-efi/squash4.mod "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/grub2/x86_64-efi/xzio.mod to /run/cos/state/grub2/x86_64-efi/xzio.mod "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:29Z] Identified source system as suse             "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/lib64/efi/shim.efi to /run/cos/efi/EFI/boot/shim.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/lib64/efi/shim.efi to /run/cos/efi/EFI/elemental/shim.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/efi/x86_64/shim.efi to /run/cos/efi/EFI/boot/shim.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/efi/x86_64/shim.efi to /run/cos/efi/EFI/elemental/shim.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/lib64/efi/MokManager.efi to /run/cos/efi/EFI/boot/MokManager.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/lib64/efi/MokManager.efi to /run/cos/efi/EFI/elemental/MokManager.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/efi/x86_64/MokManager.efi to /run/cos/efi/EFI/boot/MokManager.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/efi/x86_64/MokManager.efi to /run/cos/efi/EFI/elemental/MokManager.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/lib64/efi/grub.efi to /run/cos/efi/EFI/boot/grub.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/lib64/efi/grub.efi to /run/cos/efi/EFI/elemental/grub.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/efi/x86_64/grub.efi to /run/cos/efi/EFI/boot/grub.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/efi/x86_64/grub.efi to /run/cos/efi/EFI/elemental/grub.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/grub2/x86_64-efi/grub.efi to /run/cos/efi/EFI/boot/grub.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Copying /run/cos/workingtree/usr/share/grub2/x86_64-efi/grub.efi to /run/cos/efi/EFI/elemental/grub.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Creating boot entry for elemental pointing to shim /EFI/elemental/shim.efi "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:29Z] Entry created for elemental-shim in the EFI boot manager "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:29Z] Using grub config file /run/cos/workingtree/etc/cos/grub.cfg "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:29Z] Copying grub config file from /run/cos/workingtree/etc/cos/grub.cfg to /run/cos/state/grub2/grub.cfg "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Mounting /run/cos/workingtree/dev to chroot  "
time="2025-07-06T03:18:29Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:29Z] Mounting /run/cos/workingtree/dev/pts to chroot "
time="2025-07-06T03:18:30Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:30Z] Mounting /run/cos/workingtree/proc to chroot "
time="2025-07-06T03:18:30Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:30Z] Mounting /run/cos/workingtree/sys to chroot  "
time="2025-07-06T03:18:30Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:30Z] Mounting /run/cos/workingtree/oem to chroot  "
time="2025-07-06T03:18:30Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:30Z] Mounting /run/cos/workingtree/usr/local to chroot "
time="2025-07-06T03:18:30Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:30Z] Running cmd: 'setfiles -c /etc/selinux/targeted/policy/policy.33 -e /dev -e /proc -e /sys -F /etc/selinux/targeted/contexts/files/file_contexts /' "
time="2025-07-06T03:18:39Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:39Z] SELinux setfiles output:                     "
time="2025-07-06T03:18:39Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:39Z] Running cmd: 'sync '                         "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Unmounting /run/cos/workingtree/usr/local from chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Unmounting /run/cos/workingtree/oem from chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Unmounting /run/cos/workingtree/sys from chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Unmounting /run/cos/workingtree/proc from chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Unmounting /run/cos/workingtree/dev/pts from chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Unmounting /run/cos/workingtree/dev from chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Mounting /run/cos/workingtree/dev to chroot  "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Mounting /run/cos/workingtree/dev/pts to chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Mounting /run/cos/workingtree/proc to chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Mounting /run/cos/workingtree/sys to chroot  "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Mounting /run/cos/workingtree/oem to chroot  "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Mounting /run/cos/workingtree/usr/local to chroot "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:41Z] Running after-install-chroot hook            "
time="2025-07-06T03:18:41Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:41Z] Running cmd: 'sync '                         "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Unmounting /run/cos/workingtree/usr/local from chroot "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Unmounting /run/cos/workingtree/oem from chroot "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Unmounting /run/cos/workingtree/sys from chroot "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Unmounting /run/cos/workingtree/proc from chroot "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Unmounting /run/cos/workingtree/dev/pts from chroot "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Unmounting /run/cos/workingtree/dev from chroot "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:42Z] Running after-install hook                   "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Running grub2-editenv with params: /run/cos/state/grub_oem_env set state_label=COS_STATE "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Running cmd: 'grub2-editenv /run/cos/state/grub_oem_env set state_label=COS_STATE' "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Running grub2-editenv with params: /run/cos/state/grub_oem_env set active_label=COS_ACTIVE "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Running cmd: 'grub2-editenv /run/cos/state/grub_oem_env set active_label=COS_ACTIVE' "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Running grub2-editenv with params: /run/cos/state/grub_oem_env set passive_label=COS_PASSIVE "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Running cmd: 'grub2-editenv /run/cos/state/grub_oem_env set passive_label=COS_PASSIVE' "
time="2025-07-06T03:18:42Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Running grub2-editenv with params: /run/cos/state/grub_oem_env set recovery_label=COS_RECOVERY "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:42Z] Running cmd: 'grub2-editenv /run/cos/state/grub_oem_env set recovery_label=COS_RECOVERY' "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running grub2-editenv with params: /run/cos/state/grub_oem_env set system_label=COS_SYSTEM "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running cmd: 'grub2-editenv /run/cos/state/grub_oem_env set system_label=COS_SYSTEM' "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running grub2-editenv with params: /run/cos/state/grub_oem_env set oem_label=COS_OEM "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running cmd: 'grub2-editenv /run/cos/state/grub_oem_env set oem_label=COS_OEM' "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running grub2-editenv with params: /run/cos/state/grub_oem_env set persistent_label=COS_PERSISTENT "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running cmd: 'grub2-editenv /run/cos/state/grub_oem_env set persistent_label=COS_PERSISTENT' "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Looking for GRUB_ENTRY_NAME name in /run/cos/workingtree/etc/os-release "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:43Z] Setting default grub entry to Harvester v1.5.0 "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running grub2-editenv with params: /run/cos/state/grub_oem_env set default_menu_entry=Harvester v1.5.0 "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running cmd: 'grub2-editenv /run/cos/state/grub_oem_env set default_menu_entry=Harvester v1.5.0' "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:43Z] Creating filesystem image /run/cos/state/cOS/active.img with size: 3072 "
time="2025-07-06T03:18:43Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:43Z] Running cmd: 'mkfs.ext2 -L COS_ACTIVE /run/cos/state/cOS/active.img' "
time="2025-07-06T03:18:44Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:44Z] Mounting image COS_ACTIVE to /run/cos/active "
time="2025-07-06T03:18:44Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:44Z] Running cmd: 'losetup --show -f /run/cos/state/cOS/active.img' "
time="2025-07-06T03:18:44Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:44Z] Sync /run/cos/workingtree to /run/cos/active "
time="2025-07-06T03:18:44Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:18:44Z] Starting rsync...                            "
time="2025-07-06T03:18:44Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:44Z] Running cmd: 'rsync --progress --partial --human-readable --archive --xattrs --acls /run/cos/workingtree/ /run/cos/active/' "
time="2025-07-06T03:18:49Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:49Z] Syncing data...                              "
time="2025-07-06T03:18:54Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:54Z] Syncing data...                              "
time="2025-07-06T03:18:59Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:18:59Z] Syncing data...                              "
time="2025-07-06T03:19:02Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:19:02Z] Finished syncing                             "
time="2025-07-06T03:19:02Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:19:02Z] Unmounting image COS_ACTIVE from /run/cos/active "
time="2025-07-06T03:19:11Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:19:11Z] Running cmd: 'losetup -d /dev/loop1'         "
time="2025-07-06T03:19:12Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:19:12Z] Copying image /run/cos/state/cOS/active.img to /run/cos/recovery/cOS/recovery.img "
time="2025-07-06T03:19:15Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:19:15Z] Setting label: COS_SYSTEM                    "
time="2025-07-06T03:19:15Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:19:15Z] Running cmd: 'tune2fs -L COS_SYSTEM /run/cos/recovery/cOS/recovery.img' "
time="2025-07-06T03:19:43Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:19:43Z] Copying image /run/cos/state/cOS/active.img to /run/cos/state/cOS/passive.img "
time="2025-07-06T03:19:46Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:19:46Z] Setting label: COS_PASSIVE                   "
time="2025-07-06T03:19:46Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:19:46Z] Running cmd: 'tune2fs -L COS_PASSIVE /run/cos/state/cOS/passive.img' "
time="2025-07-06T03:20:18Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:20:18Z] Running post-install hook                    "
time="2025-07-06T03:20:18Z" level=info msg="[stdout]: \x1b[36mINFO\x1b[0m[2025-07-06T03:20:18Z] Unmounting disk partitions                   "
time="2025-07-06T03:20:18Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:20:18Z] Unmounting partition COS_STATE               "
time="2025-07-06T03:20:19Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:20:19Z] Unmounting partition COS_RECOVERY            "
time="2025-07-06T03:20:19Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:20:19Z] Unmounting partition COS_PERSISTENT          "
time="2025-07-06T03:20:19Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:20:19Z] Unmounting partition COS_OEM                 "
time="2025-07-06T03:20:19Z" level=info msg="[stdout]: \x1b[37mDEBU\x1b[0m[2025-07-06T03:20:19Z] Unmounting partition COS_GRUB                "
time="2025-07-06T03:20:19Z" level=info msg="[stdout]: Detecting drives.."
time="2025-07-06T03:20:19Z" level=info msg="[stdout]: Mounting critical endpoints.."
time="2025-07-06T03:20:20Z" level=info msg="[stdout]: Prepared TARGET_ROOTFS (/run/cos/target)"
time="2025-07-06T03:20:20Z" level=info msg="[stdout]: Ensuring passive.img is sparse..."
time="2025-07-06T03:20:20Z" level=info msg="[stdout]:   was: 3.1G\t/tmp/mnt/STATE/cOS/passive.img"
time="2025-07-06T03:20:21Z" level=info msg="[stdout]:   now: 1.7G\t/tmp/mnt/STATE/cOS/passive.img"
time="2025-07-06T03:20:21Z" level=info msg="[stdout]: Downloading ISO.."
time="2025-07-06T03:20:21Z" level=info msg="[stdout]: Copying rancherd bootstrap images to the <TARGET_ROOTFS>/var/lib/rancher/agent/images ..."
time="2025-07-06T03:20:21Z" level=info msg="[stdout]: sending incremental file list"
time="2025-07-06T03:20:21Z" level=info msg="[stdout]: ./"
time="2025-07-06T03:20:21Z" level=info msg="[stdout]: rancherd-bootstrap-images-v1.5.0.tar.zst"
time="2025-07-06T03:20:22Z" level=info msg="[stdout]: rancherd-bootstrap-images-v1.5.0.txt"
time="2025-07-06T03:20:22Z" level=info msg="[stdout]: "
time="2025-07-06T03:20:22Z" level=info msg="[stdout]: sent 53.67M bytes  received 57 bytes  35.78M bytes/sec"
time="2025-07-06T03:20:22Z" level=info msg="[stdout]: total size is 53.66M  speedup is 1.00"
time="2025-07-06T03:20:22Z" level=info msg="[stdout]: Copying minimum RKE2 images to the <TARGET_ROOTFS>//var/lib/rancher/rke2/agent/images ..."
time="2025-07-06T03:20:22Z" level=info msg="[stdout]: sending incremental file list"
time="2025-07-06T03:20:22Z" level=info msg="[stdout]: rke2-images.linux-amd64-v1.32.3-rke2r1.tar.zst"
time="2025-07-06T03:20:39Z" level=info msg="[stdout]: "
time="2025-07-06T03:20:39Z" level=info msg="[stdout]: sent 857.25M bytes  received 35 bytes  48.99M bytes/sec"
time="2025-07-06T03:20:39Z" level=info msg="[stdout]: total size is 857.05M  speedup is 1.00"
time="2025-07-06T03:20:39Z" level=info msg="[stdout]: Bind-mount all images to temporary location."
time="2025-07-06T03:20:39Z" level=info msg="[stdout]: chroot <TARGET_ROOTFS> (/run/cos/target)"
time="2025-07-06T03:20:39Z" level=info msg="[stdout]: Extract temporary RKE2 installer package to /usr/local/tmp.eTIbCcK0Fc ..."
time="2025-07-06T03:20:39Z" level=info msg="[stderr]: time=\"2025-07-06T03:20:39Z\" level=info msg=\"Extract mapping / => /usr/local/tmp.eTIbCcK0Fc\""
time="2025-07-06T03:20:39Z" level=info msg="[stderr]: time=\"2025-07-06T03:20:39Z\" level=info msg=\"Checking local image archives in /var/lib/rancher/agent/images for index.docker.io/rancher/system-agent-installer-rke2:v1.32.3-rke2r1\""
time="2025-07-06T03:20:40Z" level=info msg="[stderr]: time=\"2025-07-06T03:20:40Z\" level=info msg=\"Extracting file installer.sh to /usr/local/tmp.eTIbCcK0Fc/installer.sh\""
time="2025-07-06T03:20:40Z" level=info msg="[stderr]: time=\"2025-07-06T03:20:40Z\" level=info msg=\"Extracting file rke2.linux-amd64.tar.gz to /usr/local/tmp.eTIbCcK0Fc/rke2.linux-amd64.tar.gz\""
time="2025-07-06T03:20:40Z" level=info msg="[stderr]: time=\"2025-07-06T03:20:40Z\" level=info msg=\"Extracting file sha256sum-amd64.txt to /usr/local/tmp.eTIbCcK0Fc/sha256sum-amd64.txt\""
time="2025-07-06T03:20:40Z" level=info msg="[stderr]: time=\"2025-07-06T03:20:40Z\" level=info msg=\"Extracting file run.sh to /usr/local/tmp.eTIbCcK0Fc/run.sh\""
time="2025-07-06T03:20:41Z" level=info msg="[stdout]: Start temporary RKE2 (/usr/local/tmp.eTIbCcK0Fc/rke2/bin/rke2) to let it install containerd ..."
time="2025-07-06T03:21:31Z" level=info msg="[stdout]: Stop temporary RKE2 and remove temporary files..."
time="2025-07-06T03:21:31Z" level=info msg="[stdout]: Start RKE2's containerd (--root=/var/lib/rancher/rke2/agent/containerd) ..."
time="2025-07-06T03:21:32Z" level=info msg="[stdout]: Loading images into RKE2's containerd image store (/var/lib/rancher/rke2/agent/containerd/...). This may take a few minutes..."
time="2025-07-06T03:21:32Z" level=info msg="[stdout]: Decompress & import /var/lib/rancher/tmp/images/harvester-images-v1.5.0.tar.zst ..."
time="2025-07-06T03:28:35Z" level=info msg="[stdout]: Decompress & import /var/lib/rancher/tmp/images/harvester-repo-images-v1.5.0.tar.zst ..."
time="2025-07-06T03:28:49Z" level=info msg="[stdout]: Decompress & import /var/lib/rancher/tmp/images/rancher-images-v2.11.0.tar.zst ..."
time="2025-07-06T03:35:43Z" level=info msg="[stdout]: Decompress & import /var/lib/rancher/tmp/images/rke2-images-multus.linux-amd64-v1.32.3-rke2r1.tar.zst ..."
time="2025-07-06T03:36:00Z" level=info msg="[stdout]: Decompress & import /var/lib/rancher/tmp/images/rke2-images.linux-amd64-v1.32.3-rke2r1.tar.zst ..."
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: Checking 52 images in /tmp/images-lists/harvester-images-v1.5.0.txt..."
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: done"
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: Checking 1 images in /tmp/images-lists/harvester-repo-images-v1.5.0.txt..."
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: done"
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: Checking 30 images in /tmp/images-lists/rancher-images-v2.11.0.txt..."
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: done"
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: Checking 2 images in /tmp/images-lists/rke2-images-multus.linux-amd64-v1.32.3-rke2r1.txt..."
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: done"
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: Checking 17 images in /tmp/images-lists/rke2-images.linux-amd64-v1.32.3-rke2r1.txt..."
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: done"
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: Stop containerd..."
time="2025-07-06T03:38:46Z" level=info msg="[stdout]: Cleanup <TARGET_ROOTFS>//var/lib/rancher/rke2/agent/images ..."
+ OK=1
+ [[ -n 1 ]]
+ /srv/repos/os_images/bin/_cleanup.sh /srv/repos/os_images/harvester1.5.0.dd
umount: /data_hdd/srv/repos/os_images/harvester1.5.0.dd.tmp/part-COS_OEM.mount (/dev/loop2p2) unmounted
detached /dev/loop2 (/srv/repos/os_images/harvester1.5.0.dd)
removed directory '/srv/repos/os_images/harvester1.5.0.dd.tmp/part-COS_OEM.mount'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/iso'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/initrd'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/http.log'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/test_timestamp'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/rootfs.squashfs'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/liveos_cloud_config_for_fixing_harv_install.yml'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/harvester_install_config.yml'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/kernel'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/ctr-check-images.sh.orig'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/harv-install.orig'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/ctr-check-images.sh'
removed '/srv/repos/os_images/harvester1.5.0.dd.tmp/harv-install'
removed directory '/srv/repos/os_images/harvester1.5.0.dd.tmp/iso.mount'
removed directory '/srv/repos/os_images/harvester1.5.0.dd.tmp'
+ [[ -n 1 ]]
[Done] prepared UEFI-only bootable image '/srv/repos/os_images/harvester1.5.0.dd'
```
