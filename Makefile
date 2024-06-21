SHELL := /bin/bash
BUILD := build_scripts/build.sh
VARIANTS = x86_64 mips nginx
# Variant targets
define VARIANT_RULES

$(1): $(1)_package

$(1)_prepare:
	$(BUILD) prepare_variant $(1)

$(1)_build: $(1)_prepare
	$(BUILD) build_variant $(1)

$(1)_rebuild: $(1)_prepare
	$(BUILD) rebuild_variant $(1)

$(1)_package: $(1)_build
	$(BUILD) package_variant $(1)

$(1)_clean:
	$(BUILD) clean_variant $(1)

endef

$(foreach variant,$(VARIANTS),$(eval $(call VARIANT_RULES,$(variant))))
