#!/bin/bash

# stolen from destinal on discord
pip3 install --upgrade lz4 git+https://github.com/marin-m/vmlinux-to-elf
vmlinux-to-elf xImage vmlinux.elf

# note # back convertion 'vmlinux.elf -> vmlinux.bin'
# prebuilts/toolchains/mips-gcc520-glibc222/bin/mips-linux-gnu-objcopy -O binary vmlinux.elf vmlinux.bin
qemu-system-mipsel -m 64M -kernel ./vmlinux.elf -serial stdio -cpu XBurstR1

