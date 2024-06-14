#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../env.sh
source $BASE_DIR/.mod_env

export VARIANT_BUILDROOT_OUT=$BUILDROOT_OUT/$MOD_VARIANT

# # Add a console on tty1
# if [ -e ${TARGET_DIR}/etc/inittab ]; then
#     grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
# 	sed -i '/GENERIC_SERIAL/a\
# tty1::respawn:/sbin/getty -L  tty1 0 vt100 # QEMU graphical window' ${TARGET_DIR}/etc/inittab
# fi

if [ "$MOD_VARIANT" == "x86_64" ]; then
    $VARIANT_BUILDROOT_OUT/host/bin/python3 -m pip install --target ${TARGET_DIR}/lib/python3.8/site-packages/ virtualenv==15.1.0 --no-deps --upgrade
fi
