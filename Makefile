TWEAK_NAME = Columba ColumbaShared

Columba_FILES = $(filter-out $(wildcard ./ColumbaSettings/*.*m), $(wildcard ./*/*.*m)) $(wildcard ./*.*m)
Columba_FRAMEWORKS = CoreGraphics UIKit Contacts Social ContactsUI MessageUI SystemConfiguration StoreKit MediaPlayer CoreLocation AVFoundation AdSupport AudioToolbox QuartzCore CFNetwork CoreMedia CoreTelephony CoreVideo GLKit CoreMotion OpenGLES MobileCoreServices
Columba_EXTRA_FRAMEWORKS = RevMobAds GoogleMobileAds
Columba_PRIVATE_FRAMEWORKS = ChatKit IMCore Preferences PersistentConnection
Columba_LIBRARIES = MobileGestalt

ColumbaShared_FILES = ./Columba/CBLocalizations.m ./Columba/CBSettingsSyncer.m ./Columba/Columba.m ./Columba/CBCommunicationsHandler.m $(wildcard ./Messages/*.*m) ./ChatKit/CKTranscriptCollectionViewController.xm

export TARGET = iphone:clang
export ARCHS = armv7 armv7s arm64
export SDKVERSION = 9.0
export ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
SUBPROJECTS += ColumbaSettings
include $(THEOS_MAKE_PATH)/aggregate.mk
