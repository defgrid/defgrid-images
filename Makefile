
BUILDROOT_VERSION=2016.08

BASE_DIR=$(abspath .)
SETUP_DIR=$(abspath setup)
DG_TOOLCHAIN_SYSROOT=$(abspath toolchain/host/usr)
BR2_DL_DIR=$(SETUP_DIR)
BR2_EXTERNAL=$(abspath config)

export BR2_DL_DIR
export BR2_EXTERNAL
export DG_TOOLCHAIN_SYSROOT

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

build/%-image/images/xen-disk.img: build/%-image/images/rootfs.ext3
	./scripts/make-disk-image build/$(*)-image/images xen

build/%-image/images/qemu-disk.img: build/%-image/images/rootfs.ext3
	./scripts/make-disk-image build/$(*)-image/images qemu

build/%-image/images/rootfs.ext3: build/%-image/.config | toolchain
	make -C $(BASE_DIR)/build/$(*)-image

build/%-image/.config: build/%-image config/common/buildroot_config config/configs/defgrid_%_defconfig | toolchain
	make O=$(BASE_DIR)/build/$(*)-image -C $(SETUP_DIR)/buildroot defgrid_$(*)_defconfig

config/configs/defgrid_%_defconfig: config/configs/defgrid_%_extconfig config/common/buildroot_config
	cat config/common/buildroot_config $< >$@

build/%-image:
	mkdir -p $@

%-xen: build/%-image/images/xen-disk.img
	echo $@

%-qemu: build/%-image/images/qemu-disk.img
	echo $@

%-emulator: %-qemu
	./scripts/launch-emulator build/$(*)-image/images

# "skeleton" is a dummy image that just contains the "common" bits that
# we include in all images, but doesn't start up any role-specific services.
skeleton: skeleton-xen skeleton-qemu

all: skeleton

.PHONY: buildroot toolchain toolchain-shell skeleton
.PRECIOUS: $(SETUP_DIR)/buildroot-$(BUILDROOT_VERSION).tar.bz2 $(SETUP_DIR)/buildroot/Makefile %.img %/.config %.ext3
.SECONDARY:
