# Building qemu image

## Host Preparation

You will need qemu, qemu-user-static and qemu-user-static-binfmt or equivalent

```
sudo ./create.sh
```

## Running it

```
./start.sh
```

## Chroot K1 Firmware rootfs

scp -P 2222 rootfs.squashfs root@localhost:/root/

Login as ssh and do:

```
cd ~
./chroot.sh
chroot rootfs/ /bin/ash
```

