
BUILDROOT_VERSION=2016.08

SETUP_DIR=setup
BR2_DL_DIR=$(abspath $(SETUP_DIR))

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

.PHONY: buildroot toolchain toolchain-shell
.PRECIOUS: $(SETUP_DIR)/buildroot-$(BUILDROOT_VERSION).tar.bz2 $(SETUP_DIR)/buildroot/Makefile
