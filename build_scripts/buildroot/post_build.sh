#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../env.sh
source $BASE_DIR/.mod_env

export VARIANT_BUILDROOT_OUT=$BUILDROOT_OUT/$MOD_VARIANT

if [ "$MOD_VARIANT" == "x86_64" ]; then
    echo "TARGET DIR: ${TARGET_DIR}"
    # this is as dodgy af but it works if you run it from a x86_64 build machine!
    ${TARGET_DIR}/usr/bin/python3 -m pip install --ignore-installed virtualenv==15.1.0 --no-deps --upgrade
fi
