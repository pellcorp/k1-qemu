# Building qemu image

## Prerequisites

You will need qemu, qemu-user-static and qemu-user-static-binfmt or equivalent and unsquashfs

### Recreate Rootfs from Firmware

You will need a linux machine with the following commands available, something like ubuntu or arch is fine:

- p7zip (7z command)
- wget
- unsquashfs
- mksquashfs
- libguestfs
- virt-make-fs
- debootstrap

The packages on ubuntu can be installed like so:

```
sudo apt-get install p7zip squashfs-tools wget debootstrap guestfs-tools libguestfs
```

The packages on arch / manjaro are the same:

```
sudo pacman -S p7zip squashfs-tools wget debootstrap guestfs-tools libguestfs
```

Don't try and create this on windows or MacOs, you could do it on a ubuntu vm no problem

### Create the Image

```
sudo ./create.sh
```

**NOTE:** You will be required to enter your `sudo` password

## Running it

```
sudo ./start.sh
```

## Chroot K1 Firmware rootfs

If you login from the console you login as root/root.   The debian root user has a .bashrc
which will run the chroot.sh automatically.

If you login via ssh once the /root/rootfs version of dropbear is started, you will need to 
login as root/creality_2023, and you will already be in the chroot context.

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
