# Original Makefile from YTLite
FINALPACKAGE = 1
ARCHS = arm64
TARGET := iphone:clang:latest:14.0

# Single source of truth for the version shown in the in-app settings.
YOUMOD_VERSION := $(shell sed -n 's/^Version:[[:space:]]*//p' control)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouMod
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DYOUMOD_VERSION='"$(YOUMOD_VERSION)"'
$(TWEAK_NAME)_FILES = $(wildcard Files/*.x)

include $(THEOS_MAKE_PATH)/tweak.mk
