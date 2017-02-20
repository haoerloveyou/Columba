//
//  CBSettingsComposeController.mm
//  
//
//  Created by Mohamed Marbouh on 2016-09-24.
//
//

#import "headers/headers.h"
#import "CBSettingsComposeController.h"
#import "CBSettingsListController.h"

@implementation CBSettingsComposeController

- (NSArray*)specifiers
{
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		PSSpecifier *hudSpecifier = [PSSpecifier preferenceSpecifierNamed:COLUMBA_STRING(@"RING_VOLUME_SLIDER", @"Volume HUD") target:CBSettingsListController.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:PSSwitchCell edit:Nil];
		hudSpecifier.identifier = @"volumeQC";
		[specifiers addObject:hudSpecifier];
        
        PSSpecifier *recents = [PSSpecifier preferenceSpecifierNamed:COLUMBA_STRING(@"CALL_HISTORY", @"Default to Recents") target:CBSettingsListController.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:PSSwitchCell edit:Nil];
        recents.identifier = @"recents";
        [specifiers addObject:recents];
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		[specifiers addObjectsFromArray:[self loadSpecifiersFromPlistName:@"ActivatorLink" target:self]];
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

@end
