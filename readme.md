# Building qemu image

## Host Preparation

You will need qemu, qemu-user-static and qemu-user-static-binfmt or equivalent and unsquashfs

### K1 Firmware 

Use the download-firmware.sh script

### Create the Image

```
sudo ./create.sh
```

## Running it

```
sudo ./start.sh
```

## Chroot K1 Firmware rootfs

Login as ssh and do:

```
./chroot.sh
```

# Default Config

You can get the creality firmware to setup basic printer data by running:

```
/etc/init.d/S55klipper_service start
```

## Console too narrow?

After `./chroot.sh`, run the `resize` command

## Links

https://github.com/wtdcode/DebianOnQEMU
https://doma.ws/debian11_mips/

