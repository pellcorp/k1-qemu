#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../env.sh
source $BASE_DIR/.mod_env

export VARIANT_BUILDROOT_OUT=$BUILDROOT_OUT/$MOD_VARIANT

if [ "$MOD_VARIANT" = "x86_64" ]; then
    mkdir -p ${TARGET_DIR}/usr/share/
    tar -zxf $GIT_ROOT/prebuilt/klippy-env.tar.gz -C ${TARGET_DIR}/usr/share/
    # the rest of the env will hopefully be binary free
    cp ${TARGET_DIR}/usr/bin/python3 ${TARGET_DIR}/usr/share/klippy-env/bin/

    # dont start nginx but leave the bin file
    [ -f ${TARGET_DIR}/etc/init.d/S50nginx ] && rm ${TARGET_DIR}/etc/init.d/S50nginx
fi
