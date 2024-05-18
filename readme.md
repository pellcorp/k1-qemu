# Building qemu image


## Prerequisites

You will need qemu, qemu-user-static and qemu-user-static-binfmt or equivalent and unsquashfs

### Recreate Rootfs from Firmware

You will need a linux machine with the following commands available, something like ubuntu or arch is fine:

- p7zip (7z command)
- wget
- unsquashfs
- mksquashfs

The packages on ubuntu can be installed like so:

```
sudo apt-get install p7zip squashfs-tools wget
```

Don't try and create this on windows or MacOs, you could do it on a ubuntu vm no problem


### Create the Image

```
export K1_FIRMWARE_PASSWORD='the password from a certain discord'
sudo -E ./create.sh
```

**NOTE:** You will be required to enter your `sudo` password

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

