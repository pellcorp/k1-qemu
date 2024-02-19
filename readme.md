# Building qemu image

## Host Preparation

You will need qemu, qemu-user-static and qemu-user-static-binfmt or equivalent and unsquashfs

```
sudo ./create.sh
```

## Running it

```
./start.sh
```

## Chroot K1 Firmware rootfs

Login as ssh and do:

```
cd ~
./chroot.sh
```

# Default Config

You can get the creality firmware to setup basic printer data by running:

```
/etc/init.d/S55klipper_service start
```

## Console too narrow?

After `./chroot.sh`, run the `resize` command
