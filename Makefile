
BUILDROOT_VERSION=2016.08

BASE_DIR=$(abspath .)
SETUP_DIR=$(abspath setup)
DG_TOOLCHAIN_SYSROOT=$(abspath toolchain/host/usr)
BR2_DL_DIR=$(SETUP_DIR)
BR2_EXTERNAL=$(abspath config)

export BR2_DL_DIR
export BR2_EXTERNAL
export DG_TOOLCHAIN_ROOT

default:
	echo We have no default make target right now

$(SETUP_DIR):
	mkdir -p $(SETUP_DIR)

$(SETUP_DIR)/buildroot-$(BUILDROOT_VERSION).tar.bz2: | $(SETUP_DIR)
	wget -O $@ https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.bz2

$(SETUP_DIR)/buildroot: | $(SETUP_DIR)
	mkdir -p $(SETUP_DIR)/buildroot

$(SETUP_DIR)/buildroot/Makefile: $(SETUP_DIR)/buildroot-$(BUILDROOT_VERSION).tar.bz2 | $(SETUP_DIR)/buildroot
	tar jxmf $< -C $(dir $@) --strip-components=1

buildroot: $(SETUP_DIR)/buildroot/Makefile

toolchain: buildroot
	$(MAKE) -C toolchain

toolchain-shell: | toolchain
	PATH=$(abspath toolchain/host/usr/bin):$(PATH) bash

# "skeleton" is a dummy image that only contains the "common" stuff.
# It's not useful beyond just testing that the common image build
# machinery is working, though in a pinch it could be used as a base
# image for some manual post-build tweaking.
skeleton: | toolchain
	make O=$(BASE_DIR)/skeleton -C $(SETUP_DIR)/buildroot defgrid_common_defconfig
	make -C $(BASE_DIR)/skeleton
	./scripts/make-disk-image skeleton/images

.PHONY: buildroot toolchain toolchain-shell skeleton
.PRECIOUS: $(SETUP_DIR)/buildroot-$(BUILDROOT_VERSION).tar.bz2 $(SETUP_DIR)/buildroot/Makefile
