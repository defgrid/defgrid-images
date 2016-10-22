########################################################################
#
# nafe
#
########################################################################

NAFE_VERSION = 0.1
NAFE_SITE = http://downloads.sourceforge.net/project/nafe/nafe/nafe-$(NAFE_VERSION)
NAFE_SOURCE = nafe-$(NAFE_VERSION).tar.gz
NAFE_LICENSE = GPL2
NAFE_LICENSE_FILES = COPYING

define HOST_NAFE_BUILD_CMDS
	cd $(@D); make
endef

define HOST_NAFE_INSTALL_CMDS
	$(INSTALL) -D -m 755 $(@D)/txt2psf $(HOST_DIR)/usr/bin/txt2psf
	$(INSTALL) -D -m 755 $(@D)/psf2txt $(HOST_DIR)/usr/bin/psf2txt
endef

$(eval $(host-generic-package))
