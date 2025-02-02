# !/bin/bash
# Build Wrapper Script for K1 Klipper Mod
set -e


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/env.sh

MULTICORE=-j$(nproc)
#####################################################
###### Buildroot Common Build Helper Functions ######
#####################################################

# initialize a buildroot build dir with config
buildroot_prepare() # args: path config_generator variant_name
{
	br_path="$1";
	br_name=$(basename "$1")
	br_config_generator="$2"
	mod_variant_name="$3"

	mkdir -p "$br_path"
	pushd "$br_path" > /dev/null

	# setup make environment, use external tree
    if [ ! -f Makefile ]; then
  		make O="$PWD" BR2_EXTERNAL="$BUILDROOT_EXT" -C "$BUILDROOT_GIT" $MULTICORE allnoconfig
  		echo "MOD_VARIANT=\"$variant\"" > .mod_env
    fi

	# backup old config
  	if [ -f .config ]; then
	    mv .config .config_old
    fi

	# generate new config from defconfigs
    $br_config_generator
    make $MULTICORE olddefconfig

	# restore old config if unchanged (keep timestamp)
    if [ -f .config_old ] && cmp --silent .config .config_old
    then
  	    mv -f .config_old .config
  	    log_info "$br_name: config up to date"
    else
        rm -f .config_old
        log_info "$br_name: config initialized"
    fi

    popd > /dev/null
}

# (re-)build a buildroot project
buildroot_build_always() # args: path make_command
{
	br_path="$1";
	br_name=$(basename "$1")
	br_make="$2 $MULTICORE"

	pushd "$br_path" > /dev/null

	if [ -e "host" ] || [ -e "images" ] || [ -e "target" ] || \
	   find build/ -mindepth 1 -maxdepth 1 ! -name buildroot-config 2> /dev/null | read; then
	   log_warn "unclean build of $br_name"
	fi

	if $br_make
	then
		log_info "$br_name: build done"
	else
		log_error "$br_name: build failed"
		exit 1
	fi

	popd > /dev/null
}


# (re-)build a buildroot build dir if not uptodate
buildroot_build_if_needed() # args: path make_command target_file
{
	br_path="$1";
	br_name=$(basename "$1")
	br_make="$2 $MULTICORE"
	br_target_file="$3"

	pushd "$br_path" > /dev/null

	if [ -f "$br_target_file" ] && [ "$br_target_file" -nt .config ]
	then
		log_info "$br_name: target up to date"
	else
		buildroot_build_always "$br_path" "$br_make"
	fi

	popd > /dev/null
}

###############################################
###### Buildroot Mod Variant Build Steps ######
###############################################

variant_env() {
	variant=$1
    br_builddir="$BUILDROOT_OUT/$variant"
    if [ "$$variant" != "mips-basic" ]; then
        br_image="$br_builddir/images/rootfs.ext2"
    else
        br_image="$br_builddir/images/rootfs.tar"
    fi
}

defconfig_variant() {
    variant_env $1
    pushd $br_builddir
  	"$BUILDROOT_GIT"/support/kconfig/merge_config.sh "$BUILDROOT_CONFIGS/$variant"
    popd > /dev/null
}

prepare_variant() {
	variant_env $1
	buildroot_prepare "$br_builddir" "defconfig_variant $variant" "$variant"
}

build_variant() {
	variant_env $1
	buildroot_build_if_needed "$br_builddir" "make" "$br_image"
}

rebuild_variant() {
	variant_env $1
	buildroot_build_always "$br_builddir" "make"
}

clean_variant() {
	variant_env $1
	rm -rf "$br_builddir"
}

package_variant() {
    variant_env $1
    if [ "$variant" != "nginx" ]; then
        cp $BUILDROOT_QEMU/start-$variant.sh $br_builddir/images/start.sh
        chmod ugo+x $br_builddir/images/start.sh
    fi
}

cd $GIT_ROOT
GIT_VERSION=$(git describe --always)

# run command
$@
