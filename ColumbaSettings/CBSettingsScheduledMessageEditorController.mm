//
//  CBSettingsScheduledMessageEditorController.m
//  
//
//  Created by Mohamed Marbouh on 2016-10-04.
//
//

#import "headers/headers.h"

#import "CBSettingsListController.h"
#import "CBSettingsScheduledMessageEditorController.h"

#import "../Columba/CBCommunicationsHandler.h"

#import <substrate.h>

@interface CBSettingsScheduledMessageEditorController ()

@property(nonatomic) NSBundle *wallpaperBundle;
@property(nonatomic) NSDictionary *message;
@property(nonatomic) UITextView *inputView;

@end

@implementation CBSettingsScheduledMessageEditorController

- (instancetype)init
{
	if((self = [super init])) {
		self.wallpaperBundle = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/Wallpaper.bundle"];
	}
	
	return self;
}

- (void)setSpecifier:(PSSpecifier*)specifier
{
	[super setSpecifier:specifier];
	
	self.message = [self messageFromRegistry:specifier.identifier];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:COLUMBA_SAVE style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
	
	self.navigationItem.title = COLUMBA_STRING(@"Prefs.ScheduledMsgs.ScheduledMsg", @"Scheduled Message");
	self.navigationItem.rightBarButtonItem = saveButton;
}

- (NSArray*)specifiers
{
	if(!_specifiers) {
		NSMutableArray *specifiers = [NSMutableArray array];
		
		PSSpecifier *recipient = [PSSpecifier preferenceSpecifierNamed:COLUMBA_STRING(@"Prefs.ScheduledMsgs.Recipient", @"Recipient") target:self set:nil get:nil detail:Nil cell:PSStaticTextCell edit:Nil];
		recipient.identifier = @"r";
		
		PSSpecifier *text = [PSSpecifier preferenceSpecifierNamed:COLUMBA_STRING(@"Prefs.ScheduledMsgs.Text", @"Text") target:CBSettingsListController.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:PSLinkCell edit:Nil];
		text.identifier = @"t";
		
		PSSpecifier *attachments = nil;
		
		if([self.message.allKeys containsObject:@"attachments"]) {
			if([self.message[@"attachments"] count] > 0) {
				attachments = [PSSpecifier preferenceSpecifierNamed:COLUMBA_STRING(@"CB.attachments", @"Attachments") target:CBSettingsListController.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:1 edit:Nil];
				attachments.identifier = @"WALLPAPER_PREVIEW";
			}
		}
		
		PSSpecifier *date = [PSSpecifier preferenceSpecifierNamed:COLUMBA_STRING(@"Prefs.ScheduledMsgs.Date", @"Date") target:CBSettingsListController.class set:@selector(setValue:forSpecifier:) get:@selector(valueForSpecifier:) detail:Nil cell:PSLinkCell edit:Nil];
		date.identifier = @"d";
		
		[specifiers addObjectsFromArray:@[recipient, text, date]];
		
		if(attachments) {
			[specifiers addObject:attachments];
		}
		
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
	PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
	
	if([specifier.identifier isEqualToString:@"p"]) {
		height = 200;
	} else if([specifier.identifier isEqualToString:@"WALLPAPER_PREVIEW"]) {
		height = 274;
	}
	
	return height;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	PSTableCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	if([cell.specifier.identifier isEqualToString:@"r"]) {
		cell.detailTextLabel.text = self.recipientName;
	} else if([cell.specifier.identifier isEqualToString:@"t"]) {
		cell.detailTextLabel.text = self.message[@"text"];
	} else if([cell.specifier.identifier isEqualToString:@"d"]) {
		cell.detailTextLabel.text = [self.message[@"date"] descriptionWithLocale:[NSLocale currentLocale]];
	} else if([cell.specifier.identifier isEqualToString:@"e"]) {
		if(!self.inputView) {
			CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath] ? : 200;
			
			self.inputView = [[UITextView alloc] init];
			self.inputView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height-3);
			self.inputView.text = cell.specifier.name;
			self.inputView.textColor = [UIColor blackColor];
			
			((PSTextViewTableCell*)cell).textView = self.inputView;
		}
	} else if([cell.specifier.identifier isEqualToString:@"p"]) {
		if(!self.datePicker) {
			cell = [[PSUIDateTimePickerCell alloc] initWithStyle:cell.style reuseIdentifier:cell.reuseIdentifier specifier:cell.specifier];
			
			self.datePicker = MSHookIvar<UIDatePicker*>(cell, "_datePicker");
			self.datePicker.date = self.message[@"date"];
			self.datePicker.minimumDate = [NSDate date];
		}
	} else if([cell.specifier.identifier isEqualToString:@"WALLPAPER_PREVIEW"]) {
		WallpaperPreviewCell *wallpaperCell = [[[self.wallpaperBundle classNamed:@"WallpaperPreviewCell"] alloc] initWithStyle:cell.style reuseIdentifier:@"WallpaperPreviewCellPSLinkCell" specifier:cell.specifier];
		wallpaperCell._thumbnailSize = CGSizeMake(137.5, 244.5);
		
		NSArray *attachments = self.message[@"attachments"];
		
		[wallpaperCell._lockScreenThumbnailButton setImage:[UIImage imageWithData:attachments[0][@"data"]] forState:UIControlStateNormal];
		
		if(attachments.count > 1) {
			[wallpaperCell._homeScreenThumbnailButton setImage:[UIImage imageWithData:attachments[1][@"data"]] forState:UIControlStateNormal];
		}
		
		cell = wallpaperCell;
	}
	
	return cell;
}

- (UIButton*)disclosureChevronForCell:(PSTableCell*)cell
{
	UIButton *disclosureChevron = nil;
	
	for(id view in cell.subviews) {
		if([view isKindOfClass:UIButton.class]) {
			disclosureChevron = view;
			break;
		}
	}
	
	return disclosureChevron;
}

- (void)dismissEditorIfNecessary
{
	if(self.inputView) {
		[self.inputView resignFirstResponder];
		
		NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.message];
		temp[@"text"] = self.inputView.text;
		
		self.message = temp;
		self.inputView = nil;
		
		[self removeSpecifierID:@"e" animated:YES];
	}
}

- (void)dismissPickerIfNecessary
{
	if(self.datePicker) {
		NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.message];
		temp[@"date"] = self.datePicker.date;
		
		self.message = temp;
		self.datePicker = nil;
		
		[self removeSpecifierID:@"p" animated:YES];
	}
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
	
	if([specifier.identifier isEqualToString:@"t"]) {
		if(self.inputView) {
			[self dismissEditorIfNecessary];
		} else {
			[self dismissPickerIfNecessary];
			
			PSSpecifier *textField = [PSSpecifier preferenceSpecifierNamed:self.message[@"text"] target:self set:nil get:nil detail:Nil cell:PSEditTextViewCell edit:Nil];
			textField.identifier = @"e";
			[textField setProperty:@200 forKey:@"height"];
			
			[self insertSpecifier:textField afterSpecifier:specifier animated:YES];
			[self.inputView becomeFirstResponder];
		}
	} else if([specifier.identifier isEqualToString:@"d"]) {
		if(self.datePicker) {
			[self dismissPickerIfNecessary];
		} else {
			[self dismissEditorIfNecessary];
			
			PSSpecifier *datePickerSpecifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:Nil cell:PSGiantCell edit:Nil];
			datePickerSpecifier.identifier = @"p";
			[datePickerSpecifier setProperty:@200 forKey:@"height"];
			
			[self insertSpecifier:datePickerSpecifier afterSpecifier:specifier animated:YES];
		}
	} else if([specifier.identifier isEqualToString:@"WALLPAPER_PREVIEW"]) {
		
	} else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
		[self dismissPickerIfNecessary];
		[self dismissEditorIfNecessary];
	}
}

- (void)unregisterMessage
{
	NSMutableArray *messages = [NSMutableArray arrayWithArray:[objc_getClass("CBSettingsSyncer") valueForKey:@"scheduledMessages"]];
	NSDictionary *message = nil;
	
	for(NSDictionary *item in messages) {
		if([item[@"memAddress"] isEqualToString:self.message[@"memAddress"]]) {
			message = item;
			break;
		}
	}
	
	if(message) {
		[messages removeObject:message];
		[objc_getClass("CBSettingsSyncer") setValue:messages forKey:@"scheduledMessages"];
	}
}

- (void)saveAction
{
	[self dismissEditorIfNecessary];
	[self dismissPickerIfNecessary];
	
	NSDate *now = [NSDate date];
	
	if([[NSCalendar currentCalendar] compareDate:now toDate:self.message[@"date"] toUnitGranularity:NSCalendarUnitSecond] == NSOrderedAscending) {
		[objc_getClass("CBCommunicationsHandler") requestTimerInvalidation:@{@"id": self.message[@"memAddress"]}];
	}
	
	[self unregisterMessage];
	[objc_getClass("CBCommunicationsHandler") requestTimerValidationForMessage:self.message];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSString*)recipientName
{
	NSString *name = nil;
	
	if([self.message.allKeys containsObject:@"displayName"]) {
		name = self.message[@"displayName"];
	} else if([self.message.allKeys containsObject:@"recipients"]) {
		NSArray *recipients = self.message[@"recipients"];
		
		if(recipients.count > 1) {
			name = COLUMBA_STRING(@"Prefs.ScheduledMsgs.MultipleRecipients", @"Multiple Recipients");
		} else if(recipients.count == 1) {
			name = recipients[0][@"displayString"];
		}
	}
	
	return name;
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

@end
