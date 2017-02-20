//
//  CBTemplatesTableViewController.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-23.
//
//

#import "CBTemplatesTableViewController.h"
#import "../headers/headers.h"

@interface CBTemplatesTableViewController ()

@property(nonatomic, retain) NSMutableDictionary *reusableCells;
@property(nonatomic) NSMutableArray *templates;

@end

@implementation CBTemplatesTableViewController

- (instancetype)init
{
	if((self = [super init])) {
		self.reusableCells = [NSMutableDictionary dictionary];
		self.templates = [NSMutableArray arrayWithArray:[CBSettingsSyncer valueForKey:@"templates"]];
		self.title = COLUMBA_TEMPLATES;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.estimatedRowHeight = 44.f;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	self.navigationController.navigationBar.translucent = YES;
	
	[CBSettingsSyncer setValue:self.templates forKey:@"templates"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.templates.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell *cell;
	NSNumber *key = @(indexPath.row);
	
	if([self.reusableCells.allKeys containsObject:key]) {
		cell = self.reusableCells[key];
	} else {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"templateCell"];
		self.reusableCells[key] = cell;
	}
	
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.text = self.templates[indexPath.row];
	
	[cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(self.delegate && [self.delegate.class conformsToProtocol:@protocol(CBTemplatesTableViewControllerDelegate)]) {
		[self.delegate viewController:self selectedTemplate:self.templates[indexPath.row] atIndexPath:indexPath];
	}
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
		[self.templates removeObjectAtIndex:indexPath.row];
		
		[CBSettingsSyncer setValue:self.templates forKey:@"templates"];
		
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if(editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
	[self.templates exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];

	[CBSettingsSyncer setValue:self.templates forKey:@"templates"];
	[tableView reloadData];
}

- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

@end
