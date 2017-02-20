#import "../headers/headers.h"

#import "../Columba/CBComposeViewController.h"

@interface SBVolumeHUDView : UIView

@end

%hook SBVolumeHUDView

- (id)init
{
    SBVolumeHUDView *result = %orig;

    if([[CBSettingsSyncer valueForKey:@"volumeQC"] boolValue] && result && [[CBSettingsSyncer valueForKey:@"enabled"] boolValue]) {
		NSArray *items = @[[[%c(UIBarButtonItem) alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(CB_presentQuickCompose)]];

		UIToolbar *toolbar = [%c(UIToolbar) new];
        [toolbar setFrame:CGRectMake(CGRectGetWidth(result.frame)-25, 0, 25, 30)];
		[toolbar setBackgroundImage:[%c(UIImage) new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
		[toolbar setShadowImage:[%c(UIImage) new] forToolbarPosition:UIToolbarPositionAny];
		[toolbar setItems:items animated:YES];

        [result addSubview:toolbar];
    }

    return result;
}

%new
- (void)CB_presentQuickCompose
{
	[[CBActivatorListener sharedInstance] presentQuickComposeWindow:QuickComposeMode];
}

%end
