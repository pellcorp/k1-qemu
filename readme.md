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
#ifconfig enp0s19 192.168.5.12 up
cd ~
./chroot.sh
```

