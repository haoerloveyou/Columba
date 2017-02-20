//
//  CBSettingsTemplateEditorController.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-25.
//
//

#import "headers/headers.h"
#import "CBSettingsTemplateEditorController.h"

@interface CBSettingsTemplateEditorController ()

@property(nonatomic) NSMutableArray *templates;
@property(nonatomic) UITextView *inputView;
@property NSInteger index;

@end

@implementation CBSettingsTemplateEditorController

- (instancetype)init
{
	if((self = [super init])) {
		self.inputView = [[UITextView alloc] init];
		self.title = COLUMBA_STRING(@"Prefs.Templates.Config", @"Template Configuration");
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:COLUMBA_SAVE style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.inputView becomeFirstResponder];
}

- (NSArray*)specifiers
{
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		self.templates = [NSMutableArray arrayWithArray:[objc_getClass("CBSettingsSyncer") valueForKey:@"templates"]];
		self.index = self.specifier.identifier.intValue;
		
		PSSpecifier *textField = [PSSpecifier preferenceSpecifierNamed:self.index == -1 ? @"" : self.templates[self.index] target:self set:nil get:nil detail:Nil cell:PSEditTextViewCell edit:Nil];
		[textField setProperty:@250 forKey:@"height"];
		[specifiers addObject:textField];
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	PSTextViewTableCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath] ? : 250;
	
	self.inputView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height-3);
	self.inputView.text = cell.specifier.name;
	self.inputView.textColor = [UIColor blackColor];
	
	cell.textView = self.inputView;
	
	return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 250;
}

- (void)saveAction
{
	if(self.index == -1) {
		[self.templates insertObject:self.inputView.text atIndex:0];
	} else {
		self.templates[self.index] = self.inputView.text;
	}
	
	[objc_getClass("CBSettingsSyncer") setValue:self.templates forKey:@"templates"];
	[self.inputView resignFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
