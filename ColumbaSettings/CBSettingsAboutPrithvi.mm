//
//  CBSettingsAboutPrithvi.mm
//  
//
//  Created by Mohamed Marbouh on 2016-10-28.
//
//

#import "headers/headers.h"

#import "CBSettingsAboutPrithvi.h"

@implementation CBSettingsAboutPrithvi

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.navigationItem setTitle:@"Prithvi Karyampudi"];
}

- (NSArray*)specifiers
{
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		PSSpecifier *header = [PSSpecifier groupSpecifierWithName:@""];
		[header setProperty:@"CBSettingsAboutPrithviHeaderCell" forKey:@"headerCellClass"];
		[specifiers addObject:header];
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		NSString *name = COLUMBA_STRING(@"Prefs.Website", @"Website");
		PSSpecifier *designWeb = [PSSpecifier preferenceSpecifierNamed:name target:CBSettingsListController.class set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		MSHookIvar<SEL>(designWeb, "action") = @selector(launchSafari:);
		[designWeb setIdentifier:@"https://skyfeld.wordpress.com"];
		[designWeb setProperty:[UIImage imageNamed:@"Safari-black.png" inBundle:bundle() compatibleWithTraitCollection:nil] forKey:@"iconImage"];
		[specifiers addObject:designWeb];
		
		PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"@skyfeld" target:CBSettingsListController.class set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		MSHookIvar<SEL>(twitter, "action") = @selector(launchTwitter:);
		[twitter setIdentifier:@"skyfeld"];
		[twitter setProperty:[UIImage imageNamed:@"Twitter-black.png" inBundle:bundle() compatibleWithTraitCollection:nil] forKey:@"iconImage"];
		[specifiers addObject:twitter];
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (id)tableView:(id)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	PSTableCell *orig = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	[orig titleLabel].textColor = [UIColor blackColor];
	
	return orig;
}

@end
