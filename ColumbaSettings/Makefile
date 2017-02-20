include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ColumbaSettings
ColumbaSettings_FILES = $(wildcard ./*.*m) $(wildcard ./*/*.*m) ../common.m
ColumbaSettings_INSTALL_PATH = /Library/PreferenceBundles
ColumbaSettings_LIBRARIES = MobileGestalt
ColumbaSettings_FRAMEWORKS = UIKit CoreGraphics QuartzCore
ColumbaSettings_PRIVATE_FRAMEWORKS = Preferences PreferencesUI

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/columbasettings.plist$(ECHO_END)
