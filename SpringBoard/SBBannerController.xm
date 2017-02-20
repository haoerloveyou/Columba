#import "../headers/headers.h"
#import <substrate.h>

#import "../Columba/CBReplyWindowViewController.h"

@interface SBBannerController : NSObject

- (void)_playSoundIfNecessaryForContext:(id)arg1;

@end

%hook SBBannerController

- (void)_presentBannerForContext:(SBUIBannerContext*)context reason:(NSInteger)reason
{
    BBBulletin *bulletin = nil;
    id item = context.item;

    if([item respondsToSelector:@selector(seedBulletin)]) {
        bulletin = [item seedBulletin];
    } else if([item respondsToSelector:@selector(_bulletinListItem)]) {
        id listItem = [item _bulletinListItem];
        if([listItem respondsToSelector:@selector(activeBulletin)]) {
            bulletin = [listItem activeBulletin];
        }
    }

    if(bulletin && [bulletin.sectionID isEqualToString:@"com.apple.MobileSMS"] && [[CBSettingsSyncer valueForKey:@"enabled"] boolValue] && [[CBSettingsSyncer valueForKey:@"qrEnabled"] boolValue]) {
		if([CBActivatorListener sharedInstance].isVisible) {
			%orig;
		} else {
			CBReplyWindowMode mode = Uninitialized;

	        if(reason == 3) {
				[self _playSoundIfNecessaryForContext:context];

	            mode = NewNotificationMode;
	        } else if(reason == 0) {
	            mode = QuickReplyMode;
	        }

			[[CBActivatorListener sharedInstance] presentQuickReplyWindowWithBulletin:bulletin mode:mode attachments:nil];
		}
    } else {
        %orig;
    }
}

%end
