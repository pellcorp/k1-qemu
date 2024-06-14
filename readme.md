# K1 Qemu

## Debian and Chroot CrealityOS

So I have various things in this project, the original idea was a debian mips qemu image with
chroot for creality firmware.   I have found this to be very slow.

Refer to legacy/readme.md for more information

## X86 Buildroot

I've started working on a X86 buildroot 2020.02.1 image which will have the same basic layout and versions of tools as CrealityOS,
except will be X86_64 based, so should be a lot faster to test basic things like my Simple AF installer.

### Building it

```
docker run -ti -v $PWD:$PWD pellcorp/k1-klipper-fw-build /bin/bash -c "cd $PWD && make x86_64"
```

### Running

```
build_output/buildroot/x86_64/images/start.sh
```

## MIPS Buildroot

I am also playing around with the idea of creating a MIPS kernel for build root which would allow me to directly boot the CrealityOS rootfs
with my own kernel running the same version of linux, so far I have had mixed success, I might also just clone my X86_64 config file
to have a MIPS based copy of CrealityOS, so I can run things like my k1 klipper without any hacks.

### Building

```
docker run -ti -v $PWD:$PWD pellcorp/k1-klipper-fw-build /bin/bash -c "cd $PWD && make mips"
```

### Running

```
build_output/buildroot/mips/images/start.sh
```

## References

I copied the basic structure of reuse for buildroots from https://github.com/xblax/flashforge_ad5m_klipper_mod

This was invaluable: https://cyruscyliu.github.io/posts/2020-11-18-buildroot-qemu-x86_64/, as was this video  https://www.youtube.com/watch?v=O9RHMKJqVTg 
