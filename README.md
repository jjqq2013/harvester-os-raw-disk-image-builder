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

- To reproduce the issue, switch to the `reproduce-failure` branch.
```
(cd ./bin && git checkout reproduce-failure)
```

- Run following command to install Harvester OS to `./harvester1.5.0.dd` (raw disk image).
```
sudo ./bin/harvester1.5.0_step0_prepare_uefi_only_boot_image.sh
```

To abort the above program, you can press CTRL+C. 

You will find that the installation seemingly hangs forever, more specifically, one of the `ctr-check-images.sh` runs endlessly.
