//
//  CBMessagingWindow.xm
//  
//
//  Created by Mohamed Marbouh on 2016-10-03.
//
//

#import "../headers/headers.h"

#import "CBMessagingWindow.h"

@implementation CBMessagingWindow

- (instancetype)init
{
	if((self = [super init])) {
		self.backgroundColor = [UIColor clearColor];
		self.windowLevel = UIWindowLevelStatusBar + 100.0;
	}
	
	return self;
}

- (BOOL)shouldAffectStatusBarAppearance
{
	return self.isKeyWindow;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)makeKeyAndVisible
{
	[super makeKeyAndVisible];
	
	self.hidden = NO;
}

+ (void)initialize
{
	// This adds a method (superclass override) at runtime which gives us the status bar behavior we want.
	// The FLEX window is intended to be an overlay that generally doesn't affect the app underneath.
	// Most of the time, we want the app's main window(s) to be in control of status bar behavior.
	// Done at runtime with an obfuscated selector because it is private API. But you shoudn't ship this to the App Store anyways...
	NSString *canAffectSelectorString = [@[@"_can", @"Affect", @"Status", @"Bar", @"Appearance"] componentsJoinedByString:@""];
	SEL canAffectSelector = NSSelectorFromString(canAffectSelectorString);
	Method shouldAffectMethod = class_getInstanceMethod(self, @selector(shouldAffectStatusBarAppearance));
	IMP canAffectImplementation = method_getImplementation(shouldAffectMethod);
	class_addMethod(self, canAffectSelector, canAffectImplementation, method_getTypeEncoding(shouldAffectMethod));
	
	// One more...
	NSString *canBecomeKeySelectorString = [NSString stringWithFormat:@"_%@", NSStringFromSelector(@selector(canBecomeKeyWindow))];
	SEL canBecomeKeySelector = NSSelectorFromString(canBecomeKeySelectorString);
	Method canBecomeKeyMethod = class_getInstanceMethod(self, @selector(canBecomeKeyWindow));
	IMP canBecomeKeyImplementation = method_getImplementation(canBecomeKeyMethod);
	class_addMethod(self, canBecomeKeySelector, canBecomeKeyImplementation, method_getTypeEncoding(canBecomeKeyMethod));
}

@end