#import "../headers/headers.h"

@interface SBHUDWindow : UIWindow

@end

%hook SBHUDWindow

- (BOOL)_ignoresHitTest
{
    if([[CBSettingsSyncer valueForKey:@"volumeQC"] boolValue] && [[CBSettingsSyncer valueForKey:@"enabled"] boolValue]) {
		self.userInteractionEnabled = YES;
		return NO;
    } else {
        return %orig;
    }
}

%end
