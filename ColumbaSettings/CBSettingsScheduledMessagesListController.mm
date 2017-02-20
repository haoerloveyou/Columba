//
//  CBSettingsScheduledMessagesListController.mm
//  
//
//  Created by Mohamed Marbouh on 2016-10-04.
//
//

#import "headers/headers.h"

#import "CBSettingsScheduledMessagesListController.h"
#import "CBSettingsScheduledMessageEditorController.h"

#import "../Columba/CBCommunicationsHandler.h"

@interface CBSettingsScheduledMessagesListController ()

@property(nonatomic) NSDateFormatter *dateFormatter;
@property(nonatomic) NSMutableArray *messages;

@end

@implementation CBSettingsScheduledMessagesListController

- (instancetype)init
{
	if((self = [super init])) {
		self.dateFormatter = [NSDateFormatter new];
		self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tappedAddButton)];
}

- (void)prettyReload:(BOOL)animated
{
	UITableView *tableView = MSHookIvar<UITableView*>(self, "_table");
	
	if(tableView.numberOfSections > 1) {
		UITableViewRowAnimation animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
		
		[CATransaction begin];
		
		[CATransaction setCompletionBlock:^{
			[self reloadSpecifiers];
		}];
		
		[tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, tableView.numberOfSections-1)] withRowAnimation:animation];
		
		[CATransaction commit];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self prettyReload:animated];
}

- (NSArray*)specifiers
{
	if(!_specifiers) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		NSString *name = COLUMBA_STRING(@"Prefs.ScheduledMsgs.ScheduleMsg", @"Schedule Message");
		PSSpecifier *newMessage = [PSSpecifier preferenceSpecifierNamed:name target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		newMessage.identifier = @"-1";
		[specifiers addObject:newMessage];
		
		self.messages = [NSMutableArray arrayWithArray:[objc_getClass("CBSettingsSyncer") valueForKey:@"scheduledMessages"]];
		
		if(self.messages.count > 0) {
			NSMutableArray *pastGroup = [NSMutableArray array];
			NSMutableArray *futureGroup = [NSMutableArray array];
			
			for(int i = 0; i < self.messages.count; i++) {
				NSDate *now = [NSDate date];
				NSDictionary *message = self.messages[i];
				
				NSString *title = @"";
				
				if([message[@"text"] length] > 0) {
					title = message[@"text"];
				} else if([message.allKeys containsObject:@"attachments"]) {
					title = [NSString stringWithFormat:COLUMBA_STRING(@"1_ATTACHMENT", @"%@ Attachments"), @([message[@"attachments"] count])];
				}
				
				PSSpecifier *msgSpecifier = [PSSpecifier preferenceSpecifierNamed:title target:CBSettingsListController.class set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:Nil cell:PSStaticTextCell edit:Nil];
				msgSpecifier.identifier = message[@"memAddress"];
				
				if([[NSCalendar currentCalendar] compareDate:now toDate:message[@"date"] toUnitGranularity:NSCalendarUnitSecond] == NSOrderedDescending) {
					if(pastGroup.count == 0) {
						name = COLUMBA_STRING(@"Prefs.ScheduledMsgs.Past", @"Past");
						[pastGroup addObject:[PSSpecifier groupSpecifierWithName:name]];
					}
					
					[pastGroup addObject:msgSpecifier];
				} else if([[NSCalendar currentCalendar] compareDate:now toDate:message[@"date"] toUnitGranularity:NSCalendarUnitSecond] == NSOrderedAscending) {
					if(futureGroup.count == 0) {
						name = COLUMBA_STRING(@"Prefs.ScheduledMsgs.Future", @"Future");
						[futureGroup addObject:[PSSpecifier groupSpecifierWithName:name]];
					}
					
					[futureGroup addObject:msgSpecifier];
				}
			}
			
			if(futureGroup.count > 0) {
				[specifiers addObjectsFromArray:futureGroup];
			}
			
			if(pastGroup.count > 0) {
				[specifiers addObjectsFromArray:pastGroup];
			}
		}
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	PSTableCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	if([cell.specifier.identifier isEqualToString:@"-1"]) {
		[self tappedAddButton];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		if(MSHookIvar<SEL>(cell.specifier, "action")) {
			[super tableView:tableView didSelectRowAtIndexPath:indexPath];
		}
		
		CBSettingsScheduledMessageEditorController *controller = [[CBSettingsScheduledMessageEditorController alloc] init];
		
		[controller setSpecifier:cell.specifier];
		[self pushController:controller animate:YES];
	}
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	return indexPath.section >= 1 ? YES : [super tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (NSDictionary*)messageFromRegistry:(NSString*)identifier
{
	NSArray *messages = [objc_getClass("CBSettingsSyncer") valueForKey:@"scheduledMessages"];
	NSDictionary *message = nil;
	
	for(NSDictionary *item in messages) {
		if([item[@"memAddress"] isEqualToString:identifier]) {
			message = item;
			break;
		}
	}
	
	return message;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		PSTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		PSSpecifier *specifier = cell.specifier;
		NSDictionary *message = [self messageFromRegistry:specifier.identifier];
		
		if([[self tableView:tableView titleForHeaderInSection:indexPath.section] isEqualToString:COLUMBA_STRING(@"Prefs.ScheduledMsgs.Future", @"Future")]) {
			[objc_getClass("CBCommunicationsHandler") requestTimerInvalidation:@{@"id": message[@"memAddress"]}];
		}
		
		[self.messages removeObject:message];
		
		[objc_getClass("CBSettingsSyncer") setValue:self.messages forKey:@"scheduledMessages"];
		
		[self removeSpecifier:specifier animated:YES];
	}
}

- (NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString *result = COLUMBA_DELETE;
	
	if([[self tableView:tableView titleForHeaderInSection:indexPath.section] isEqualToString:COLUMBA_STRING(@"Prefs.ScheduledMsgs.Future", @"Future")]) {
		result = COLUMBA_CANCEL;
	}
	
	return result;
}

- (void)tappedAddButton
{
	[objc_getClass("CBCommunicationsHandler") requestQuickCompose:ScheduleMode];
}

@end
