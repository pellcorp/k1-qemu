# K1 Qemu

## Debian and Chroot CrealityOS

So I have various things in this project, the original idea was a debian mips qemu image with
chroot for creality firmware.   I have found this to be very slow.

Refer to legacy/readme.md for more information

## X86 Buildroot

I've started working on a X86 buildroot 2020.02.1 image which will have the same basic layout and versions of tools as CrealityOS,
except will be X86_64 based, so should be a lot faster to test basic things like my Simple AF installer.

TODO

It is a work in progress

## MIPS Buildroot

I am also playing around with the idea of creating a MIPS kernel for build root which would allow me to directly boot the CrealityOS rootfs
with my own kernel running the same version of linux, so far I have had mixed success, I might also just clone my X86_64 config file
to have a MIPS based copy of CrealityOS, so I can run things like my k1 klipper without any hacks.

## References

I copied the basic structure of reuse for buildroots from https://github.com/xblax/flashforge_ad5m_klipper_mod

