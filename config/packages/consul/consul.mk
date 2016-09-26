########################################################################
#
# consul
#
########################################################################

CONSUL_VERSION = v0.7.0
CONSUL_SITE = $(call github,hashicorp,consul,$(CONSUL_VERSION))
CONSUL_LICENSE = MPL2
CONSUL_LICENSE_FILES = LICENSE

CONSUL_DEPENDENCIES = host-go

CONSUL_GOPATH = "$(@D)/.buildroot-gopath"
CONSUL_MAKE_ENV = $(HOST_GO_TARGET_ENV) \
	CGO_ENABLED=0 \
	GOBIN="$(@D)/bin" \
	GOPATH="$(CONSUL_GOPATH)" \
	GO15VENDOREXPERIMENT=1

CONSUL_GLDFLAGS = \
	-X github.com/hashicorp/consul/version.Version=$(CONSUL_VERSION)

ifeq ($(BR2_STATIC_LIBS),y)
CONSUL_GLDFLAGS += -extldflags '-static'
endif

define CONSUL_CONFIGURE_CMDS
	mkdir -p $(CONSUL_GOPATH)/src/github.com/hashicorp
	ln -s $(@D) $(CONSUL_GOPATH)/src/github.com/hashicorp/consul
endef

define CONSUL_BUILD_CMDS
	cd $(@D); $(CONSUL_MAKE_ENV) $(HOST_DIR)/usr/bin/go build \
	    -v -o $(@D)/bin/consul -ldflags "$(CONSUL_GLDFLAGS)" github.com/hashicorp/consul
endef

define CONSUL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/bin/consul $(TARGET_DIR)/usr/bin/consul
endef

$(eval $(generic-package))
