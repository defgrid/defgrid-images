########################################################################
#
# defgrid-init
#
########################################################################

# If you're working on both defgrid-init and defgrid-images concurrently,
# set the DEFGRID_INIT_DEV_DIR variable to point to your defgrid-init
# repository's work tree.
ifdef DEFGRID_INIT_DEV_DIR
DEFGRID_INIT_VERSION = DEV
DEFGRID_INIT_SITE = $(DEFGRID_INIT_DEV_DIR)
DEFGRID_INIT_SITE_METHOD = local
else
DEFGRID_INIT_VERSION = v0.0.0
DEFGRID_INIT_SITE = $(call github,defgrid,defgrid-init,$(DEFGRID_INIT_VERSION))
endif

DEFGRID_INIT_LICENSE = MIT
DEFGRID_INIT_LICENSE_FILES = LICENSE

DEFGRID_INIT_DEPENDENCIES = host-go

DEFGRID_INIT_GOPATH = "$(@D)/.buildroot-gopath"
DEFGRID_INIT_MAKE_ENV = $(HOST_GO_TARGET_ENV) \
	CGO_ENABLED=0 \
	GOBIN="$(@D)/bin" \
	GOPATH="$(DEFGRID_INIT_GOPATH)" \
	GO15VENDOREXPERIMENT=1

DEFGRID_INIT_GLDFLAGS = \
	-X github.com/defgrid/defgrid-init/version.Version=$(DEFGRID_INIT_VERSION)

ifeq ($(BR2_STATIC_LIBS),y)
DEFGRID_INIT_GLDFLAGS += -extldflags '-static'
endif

define DEFGRID_INIT_CONFIGURE_CMDS
	mkdir -p $(DEFGRID_INIT_GOPATH)/src/github.com/defgrid
	ln -s $(@D) $(DEFGRID_INIT_GOPATH)/src/github.com/defgrid/defgrid-init
endef

define DEFGRID_INIT_BUILD_CMDS
	cd $(@D); $(DEFGRID_INIT_MAKE_ENV) $(HOST_DIR)/usr/bin/go build \
	    -v -o $(@D)/bin/defgrid-init -ldflags "$(DEFGRID_INIT_GLDFLAGS)" github.com/defgrid/defgrid-init
endef

define DEFGRID_INIT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/bin/defgrid-init $(TARGET_DIR)/sbin/defgrid-init
endef

$(eval $(generic-package))

