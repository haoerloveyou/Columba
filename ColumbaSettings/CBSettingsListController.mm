#import "CBSettingsListController.h"
#import "CBSettingsAboutPageController.h"
#import "CBSettingsComposeController.h"
#import "CBSettingsTemplatesListController.h"
#import "CBSettingsScheduledMessagesListController.h"
#import "CBSettingsSupportListController.h"

#import <objc/runtime.h>

static void link(NSString *key, NSString *backup, Class linkedClass, NSString *imageName, NSMutableArray *specifiers)
{
	NSString *name = [[objc_getClass("CBLocalizations") sharedInstance] localizedString:key backup:backup];
	PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:name target:objc_getClass("CBSettingsSyncer") set:@selector(setValue:forKey:) get:@selector(valueForKey:) detail:linkedClass cell:PSLinkCell edit:Nil];
	specifier.identifier = key;
	setImage(specifier, imageName);
	[specifiers addObject:specifier];
}

@implementation CBSettingsListController

- (NSArray*)specifiers
{
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		PSSpecifier *header = [PSSpecifier groupSpecifierWithName:@""];
		[header setProperty:@"CBSettingsHeaderLogoCell" forKey:@"headerCellClass"];
		[specifiers addObject:header];
		
		NSString *name = COLUMBA_STRING(@"ON_CALL_OK_ENABLE", @"Enabled");
		PSSpecifier *enabled = [PSSpecifier preferenceSpecifierNamed:name target:self.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:PSSwitchCell edit:Nil];
		enabled.identifier = @"enabled";
		setImage(enabled, @"Shutdown");
		[specifiers addObject:enabled];
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		name = COLUMBA_STRING(@"Prefs.Windowed", @"Quick Reply");
		PSSpecifier *windowed = [PSSpecifier preferenceSpecifierNamed:name target:self.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:PSSwitchCell edit:Nil];
		windowed.identifier = @"qrEnabled";
		setImage(windowed, @"Change Theme Filled");
		[specifiers addObject:windowed];
		
        link(@"Prefs.QC", @"Quick Compose", CBSettingsComposeController.class, @"Create New", specifiers);
        
        [specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		name = COLUMBA_STRING(@"GRAY_SCALE", @"Dark mode");
		PSSpecifier *grayscale = [PSSpecifier preferenceSpecifierNamed:name target:self.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:PSSwitchCell edit:Nil];
		grayscale.identifier = @"grayscaleOSK";
		setImage(grayscale, @"Keyboard");
		[specifiers addObject:grayscale];
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		link(@"Prefs.ScheduledMsgs", @"Scheduled Messages", CBSettingsScheduledMessagesListController.class, @"Plus 1 Day", specifiers);
		link(@"Prefs.Templates", @"Message Templates", CBSettingsTemplatesListController.class, @"List", specifiers);
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		link(@"Prefs.Support", @"Support", CBSettingsSupportListController.class, @"Support", specifiers);
		link(@"Prefs.About", @"About", CBSettingsAboutPageController.class, @"Info", specifiers);
		
		PSSpecifier *footer = [PSSpecifier groupSpecifierWithName:@""];
		[footer setProperty:@"CBSettingsFooterCell" forKey:@"footerCellClass"];
		[specifiers addObject:footer];
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

+ (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier
{
	[objc_getClass("CBSettingsSyncer") setValue:value forKey:specifier.identifier];
}

+ (id)valueForSpecifier:(PSSpecifier*)specifier
{
	return [objc_getClass("CBSettingsSyncer") valueForKey:specifier.identifier];
}

+ (void)launchSafari:(PSSpecifier*)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:specifier.identifier]];
}

+ (void)launchTwitter:(PSSpecifier*)specifier
{
	NSString *url = [NSString stringWithFormat:@"twitter://user?screen_name=%@", specifier.identifier];
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	} else {
		url = [NSString stringWithFormat:@"https://mobile.twitter.com/%@", specifier.identifier];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}

@end

NSBundle *bundle()
{
	return [NSBundle bundleWithPath:@"/Library/Application Support/Columba/Resources.bundle"];
}

void setImage(PSSpecifier *specifier, NSString *imageName)
{
	NSString *name = [NSString stringWithFormat:@"%@.png", imageName];
	[specifier setProperty:[UIImage imageNamed:name inBundle:bundle() compatibleWithTraitCollection:nil] forKey:@"iconImage"];
}
