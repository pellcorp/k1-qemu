# Why

Run mipsel qemu image so I can play around with creality firmware rootfs stuff

I found a blog which explained a few things to get me started, even though there were bugs:

https://boschko.ca/qemu-emulating-firmware/

Unfortunately the vmlinux-3.2.0-4-4kc-malta and debian_wheezy_mips_standard.qcow2 downloaded from https://people.debian.org/~aurel32/qemu/mipsel/ are too old!!!

# dqib

Found this project which builds new debian images of various things:

https://gitlab.com/giomasce/dqib

Anyway, I found the very last mipsel build made which is available here:
https://gitlab.com/giomasce/dqib/-/jobs/4960385909

Useful info from here:
https://gitlab.com/giomasce/dqib/-/blob/d64002db448f4f3012183841cddbded6aed670d9/.gitlab-ci.yml

## Running it

qemu-system-mipsel -machine malta -cpu 4KEc -m 1G -drive file=image.qcow2 -device e1000,netdev=net -netdev user,id=net,hostfwd=tcp::2222-:22 -kernel kernel -initrd initrd -nographic -append "root=LABEL=rootfs console=ttyS0"

## Copying k1 squashfs

scp -P 2222 rootfs.squashfs root@localhost:

Login as ssh and do:

mount -t squashfs /root/squashfs-tools /mnt
cp -av /mnt/. /root/squashfs
mount -o bind /dev /root/squashfs/dev
mount -t proc /proc /root/squashfs/proc
mount -o bind /sys /root/squashfs/sys
mount -t devpts none /root/squashfs/dev/pts

chroot squashfs/ /bin/ash

