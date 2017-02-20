//
//  CBSettingsTemplatesListController.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-25.
//
//

#import "headers/headers.h"
#import "CBSettingsListController.h"
#import "CBSettingsTemplatesListController.h"
#import "CBSettingsTemplateEditorController.h"

#import <substrate.h>

@interface CBSettingsTemplatesListController ()

@property(nonatomic) NSMutableArray *templates;

@end

@implementation CBSettingsTemplatesListController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tappedAddButton)];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	UITableView *tableView = MSHookIvar<UITableView*>(self, "_table");
	UITableViewRowAnimation animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
	
	[CATransaction begin];
	
	[CATransaction setCompletionBlock:^{
		[self reloadSpecifiers];
	}];
	
	[tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:animation];
	
	[CATransaction commit];
}

- (NSArray*)specifiers
{
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		NSString *name = COLUMBA_STRING(@"Prefs.Templates.Create", @"Create Template");
		PSSpecifier *newTemplate = [PSSpecifier preferenceSpecifierNamed:name target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
		newTemplate.identifier = @"-1";
		[specifiers addObject:newTemplate];
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:@""]];
		
		self.templates = [NSMutableArray arrayWithArray:[objc_getClass("CBSettingsSyncer") valueForKey:@"templates"]];
		
		if(self.templates.count > 0) {
			for(int i = 0; i < self.templates.count; i++) {
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:self.templates[i] target:CBSettingsListController.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:PSStaticTextCell edit:Nil];
				specifier.identifier = [NSString stringWithFormat:@"%d", i];
				
				[specifiers addObject:specifier];
			}
		}
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (PSTableCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	PSTableCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	if(cell.specifier.identifier.intValue >= 0) {
		cell.textLabel.numberOfLines = 0;
		
		[cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	}
	
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	PSTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	CBSettingsTemplateEditorController *controller = [[CBSettingsTemplateEditorController alloc] init];
	controller.specifier = cell.specifier;
	
	[self pushController:controller animate:YES];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	return indexPath.section == 1 ? YES : [super tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		PSTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		PSSpecifier *specifier = cell.specifier;
		
		[self.templates removeObjectAtIndex:indexPath.row];
		
		[objc_getClass("CBSettingsSyncer") setValue:self.templates forKey:@"templates"];
		
		[self removeSpecifier:specifier animated:YES];
	}
}

- (void)tappedAddButton
{
	PSSpecifier *specifier = [[PSSpecifier alloc] init];
	specifier.identifier = @"-1";
	
	CBSettingsTemplateEditorController *controller = [[CBSettingsTemplateEditorController alloc] init];
	controller.specifier = specifier;
	
	[self pushController:controller animate:YES];
}

@end
