#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../env.sh
source $BASE_DIR/.mod_env

export VARIANT_BUILDROOT_OUT=$BUILDROOT_OUT/$MOD_VARIANT

mkdir -p ${TARGET_DIR}/usr/share/
tar -zxf $GIT_ROOT/prebuilt/klippy-env.tar.gz -C ${TARGET_DIR}/usr/share/
# the rest of the env will hopefully be binary free
cp ${TARGET_DIR}/usr/bin/python3 ${TARGET_DIR}/usr/share/klippy-env/bin/

if [ "$MOD_VARIANT" == "x86_64" ]; then
    # this is as dodgy af but it works if you run it from a x86_64 build machine!
    ${TARGET_DIR}/usr/bin/python3 -m pip install --ignore-installed virtualenv==15.1.0 --no-deps --upgrade
fi

# I am sure there is a better way, but creality packages nginx separately
# so for testing purposes we also need it separately
[ -f $VARIANT_BUILDROOT_OUT/images/nginx-$MOD_VARIANT.tar.gz ] && rm $VARIANT_BUILDROOT_OUT/images/nginx-$MOD_VARIANT.tar.gz
mkdir -p /tmp/nginx.$$/nginx/sbin
mkdir -p /tmp/nginx.$$/nginx/nginx
mkdir -p /tmp/nginx.$$/nginx/logrotate.d

# we need to redirect the nginx package separately
cp ${TARGET_DIR}/usr/sbin/nginx /tmp/nginx.$$/nginx/sbin/
cp ${TARGET_DIR}/etc/nginx/* /tmp/nginx.$$/nginx/nginx/
cp ${TARGET_DIR}/etc/logrotate.d/nginx /tmp/nginx.$$/nginx/logrotate.d/
#rm -rf ${TARGET_DIR}/usr/sbin/nginx
rm -rf ${TARGET_DIR}/etc/nginx
rm ${TARGET_DIR}/etc/init.d/S50nginx

pushd /tmp/nginx.$$ > /dev/null
tar -zcf $VARIANT_BUILDROOT_OUT/images/nginx-$MOD_VARIANT.tar.gz nginx/
popd > /dev/null
rm -rf /tmp/nginx.$$ 
