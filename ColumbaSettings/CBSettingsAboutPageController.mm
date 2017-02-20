//
//  CBSettingsAboutPageController.mm
//  
//
//  Created by Mohamed Marbouh on 2016-10-28.
//
//

#import "headers/headers.h"

#import "CBSettingsAboutIcons.h"
#import "CBSettingsAboutPageController.h"
#import "CBSettingsAboutPrithvi.h"
#import "CBSettingsSupportListController.h"

@implementation CBSettingsAboutPageController

- (NSArray*)specifiers
{
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		PSSpecifier *header = [PSSpecifier groupSpecifierWithName:@""];
		[header setProperty:@"CBSettingsHeaderLogoCell" forKey:@"headerCellClass"];
		[specifiers addObject:header];
		
		NSString *name = COLUMBA_STRING(@"CLEAR_LABEL", @"Reset All Settings");
		PSSpecifier *resetAll = [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:Nil cell:PSButtonCell edit:Nil];
		MSHookIvar<SEL>(resetAll, "action") = @selector(resetSettings);
		[specifiers addObject:resetAll];
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		name = COLUMBA_STRING(@"Developer Settings", @"Developer");
		PSSpecifier *devLink = [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:CBSettingsSupportListController.class cell:PSLinkCell edit:Nil];
		[specifiers addObject:devLink];
		
		name = COLUMBA_STRING(@"Prefs.About.Main", @"Main Icon");
		PSSpecifier *designLink = [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:CBSettingsAboutPrithvi.class cell:PSLinkCell edit:Nil];
		[specifiers addObject:designLink];
		
		name = COLUMBA_STRING(@"Prefs.About.Other", @"Other Icons");
		PSSpecifier *iconsLink = [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:CBSettingsAboutIcons.class cell:PSLinkCell edit:Nil];
		[specifiers addObject:iconsLink];
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (void)resetSettings
{
	NSString *title = COLUMBA_STRING(@"CLEAR_TITLE", @"Reset All Settings");
	NSString *detailBackup = @"Are you sure you want to continue? This will reset all settings. No data or media will be deleted.1";
	NSString *message = COLUMBA_STRING(@"CLEAR_SETTINGS_MSG_CONFIRM", detailBackup);
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:COLUMBA_CANCEL style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[alert dismissViewControllerAnimated:YES completion:nil];
	}];
	
	UIAlertAction *ok = [UIAlertAction actionWithTitle:COLUMBA_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[alert dismissViewControllerAnimated:YES completion:nil];
		[objc_getClass("CBSettingsSyncer") resetAllSettings];
	}];
	
	[alert addAction:cancel];
	[alert addAction:ok];
	[self presentViewController:alert animated:YES completion:nil];
}

@end
