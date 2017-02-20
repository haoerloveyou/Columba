//
//  CBSettingsSupportListController.mm
//  
//
//  Created by Mohamed Marbouh on 2016-10-27.
//
//

#import "headers/headers.h"

#import "CBSettingsSupportListController.h"

#import <MessageUI/MessageUI.h>

#include <sys/utsname.h>

static NSString *machineName()
{
	struct utsname systemInfo;
	uname(&systemInfo);
	return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@implementation CBSettingsSupportListController

- (NSArray*)specifiers
{
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		NSString *name = COLUMBA_STRING(@"Prefs.Support.Email", @"Send an e-mail");
		PSSpecifier *email = [PSSpecifier preferenceSpecifierNamed:name target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		MSHookIvar<SEL>(email, "action") = @selector(composeEmail);
		setImage(email, @"Message-blue");
		[specifiers addObject:email];
		
		PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"@mootjeuh" target:CBSettingsListController.class set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		MSHookIvar<SEL>(twitter, "action") = @selector(launchTwitter:);
		[twitter setIdentifier:@"mootjeuh"];
		setImage(twitter, @"Twitter-blue");
		[specifiers addObject:twitter];
		
		name = COLUMBA_STRING(@"Prefs.Support.Translate", @"Help translate Columba");
		PSSpecifier *translate = [PSSpecifier preferenceSpecifierNamed:name target:CBSettingsListController.class set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		MSHookIvar<SEL>(translate, "action") = @selector(launchSafari:);
		[translate setIdentifier:@"http://columba.mootjeuh.com/translate/"];
		setImage(translate, @"Translation-blue");
		[specifiers addObject:translate];
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)composeEmail
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	MFMailComposeViewController *controller = [objc_getClass("MFMailComposeViewController") new];
	controller.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
	[controller setToRecipients:[NSArray arrayWithObject:@"mootjeuh@outlook.com"]];
	[controller setMessageBody:[NSString stringWithFormat:@"\n\n\n%@-%@: %@", machineName(), [[UIDevice currentDevice] systemVersion], udid()] isHTML:NO];
	
	checkForPayment(^(BOOL paid) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		[controller setSubject:[NSString stringWithFormat:@"Columba for iOS 9 %@%@", paid ? @"v" : @"", @([objc_getClass("Columba") currentVersion])]];
		[self presentViewController:controller animated:YES completion:NULL];
	});
}

@end
