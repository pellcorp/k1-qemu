# Why

Run mipsel qemu image so I can play around with creality firmware rootfs stuff

I found a blog which explained a few things to get me started, even though there were bugs:

https://boschko.ca/qemu-emulating-firmware/

Unfortunately the vmlinux-3.2.0-4-4kc-malta and debian_wheezy_mips_standard.qcow2 downloaded from https://people.debian.org/~aurel32/qemu/mipsel/ are too old!!!

# dqib

Found this project which builds new debian images of various things:

https://gitlab.com/giomasce/dqib

Unfortunately I am having some issues running it locally, as mipsel is no longer supported for debian-unstable, and the debian-stable suite seems
to stall out on the `chroot "$DIR"/chroot apt-get update` step.

Anyway, I found the very last mipsel build made which is available here:
https://gitlab.com/giomasce/dqib/-/jobs/4960385909

## Docker 

### Build docker image

```
git clone https://gitlab.com/giomasce/dqib.git
cd dqib
docker build . -t dqib
```

### Run docker privileged

```
docker run --cap-add=SYS_ADMIN -it dqib
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
```

### Build mipsel

```
MIRROR=http://ftp.au.debian.org/debian/ SUITE=stable DISK_SIZE=15G MEM=512M ./create.sh mipsel-malta
```

# Running the qemu image

## Network

```
sudo brctl addbr virbr0
sudo ifconfig virbr0 192.168.5.1/24 up
# sudo ip tuntap del dev tap0 mode tap
sudo ip tuntap add dev tap0 mode tap dev tap0
sudo ifconfig tap0 192.168.5.11/24 up
sudo brctl addif virbr0 tap0
```

## Running it

qemu-system-mips -M malta -kernel vmlinux-3.2.0-4-4kc-malta -hda debian_wheezy_mips_standard.qcow2 -append "root=/dev/sda1" -netdev tap,id=tapnet,ifname=tap0,script=no -device rtl8139,netdev=tapnet -nographic

