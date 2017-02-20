//
//  CBSettingsAboutIcons.mm
//  
//
//  Created by Mohamed Marbouh on 2016-10-28.
//
//

#import "headers/headers.h"

#import "CBSettingsAboutIcons.h"

@implementation CBSettingsAboutIcons

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle:@"Icons8"];
}

- (NSArray*)specifiers
{
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		PSSpecifier *header = [PSSpecifier groupSpecifierWithName:@""];
		[header setProperty:@"CBSettingsAboutIconsHeaderCell" forKey:@"headerCellClass"];
		[specifiers addObject:header];
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		NSString *name = COLUMBA_STRING(@"Prefs.Website", @"Website");
		PSSpecifier *icons8URL = [PSSpecifier preferenceSpecifierNamed:name target:CBSettingsListController.class set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		MSHookIvar<SEL>(icons8URL, "action") = @selector(launchSafari:);
		[icons8URL setIdentifier:@"https://icons8.com"];
		[icons8URL setProperty:[UIImage imageNamed:@"Safari-green.png" inBundle:bundle() compatibleWithTraitCollection:nil] forKey:@"iconImage"];
		[specifiers addObject:icons8URL];
		
		PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"@icons_8" target:CBSettingsListController.class set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		MSHookIvar<SEL>(twitter, "action") = @selector(launchTwitter:);
		[twitter setIdentifier:@"icons_8"];
		[twitter setProperty:[UIImage imageNamed:@"Twitter-green.png" inBundle:bundle() compatibleWithTraitCollection:nil] forKey:@"iconImage"];
		[specifiers addObject:twitter];
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (id)tableView:(id)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	PSTableCell *orig = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	[orig titleLabel].textColor = UIColorFromRGB(0x3BC053);
	
	return orig;
}

@end
