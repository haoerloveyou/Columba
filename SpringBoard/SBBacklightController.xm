#import "../headers/headers.h"

@interface SBBacklightController : NSObject

- (void)resetLockScreenIdleTimer;

@end

%hook SBBacklightController

- (void)_lockScreenDimTimerFired
{
    if([[UIApplication sharedApplication].keyWindow.rootViewController.childModalViewController.class isSubclassOfClass:%c(CBMessagingWindowViewController)]) {
        [self resetLockScreenIdleTimer];
    } else {
        %orig;
    }
}

%end
