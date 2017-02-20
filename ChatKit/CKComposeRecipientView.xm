#import "../headers/headers.h"
#import "../Columba/CBAddressBarViewController.h"

%hook CKComposeRecipientView

- (void)_setAddButtonVisible:(BOOL)visible animated:(BOOL)animated
{
	if(!([self.delegate isKindOfClass:CBAddressBarViewController.class] && [CBActivatorListener sharedInstance].lockScreenManager.isUILocked)) {
		%orig;
	}
}

%end
