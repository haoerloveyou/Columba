#import "../headers/headers.h"

%hook SpringBoard

- (void)_handleMenuButtonEvent
{
	%orig;

	[[CBActivatorListener sharedInstance] dismissWindowIfPossible];
}

%end
