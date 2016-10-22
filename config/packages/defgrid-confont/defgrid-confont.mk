########################################################################
#
# defgrid-confont
#
########################################################################

DEFGRID_CONFONT_VERSION = LOCAL
DEFGRID_CONFONT_SITE_METHOD = local
DEFGRID_CONFONT_SITE = $(BR2_EXTERNAL)/packages/defgrid-confont/build

DEFGRID_CONFONT_LICENSE = GPL2
DEFGRID_CONFONT_LICENSE_FILES =

# NOTE: This also implicitly depends on psfaddtable from the host, but
# doesn't build it because so far we've been too lazy to make a
# host-installable version of the "kbd" package.
DEFGRID_CONFONT_DEPENDENCIES = host-nafe

define DEFGRID_CONFONT_BUILD_CMDS
	cd $(@D); $(HOST_DIR)/usr/bin/txt2psf glyphs.txt defgridr.psf
	cd $(@D); psfaddtable defgridr.psf codepoints.txt defgrid.psf
endef

define DEFGRID_CONFONT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 666 $(@D)/defgrid.psf $(TARGET_DIR)/usr/share/consolefonts/defgrid.psf
endef

$(eval $(generic-package))
