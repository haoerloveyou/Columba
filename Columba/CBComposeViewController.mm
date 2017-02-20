	//
//  CBComposeViewController.mm
//
//  Created by Mohamed Marbouh on 2016-09-12.
//  Copyright © 2016 Mohamed Marbouh. All rights reserved.
//

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

#import "CBComposeViewController.h"
#import "CBConversationListController.h"
#import "CBAddressBarViewController.h"
#import "CBChat.h"
#import "CBColour.h"

#import "../headers/headers.h"

#import "UIView+Glow.h"

@interface CBComposeViewController () <CKComposeRecipientSelectionControllerDelegate, CBConversationListControllerDelegate>

@property(nonatomic) CBAddressBarViewController *addressBarController;
@property(nonatomic) CKAvatarView *avatarView;
@property(nonatomic) UILabel *nameLabel;
@property(nonatomic) UIView *titleView;
@property BOOL titleViewConfigured;

@end

@implementation CBComposeViewController

- (instancetype)init
{
	if((self = [super init])) {
		self.titleViewConfigured = NO;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	if(self.conversation) {
		self.addressBarController = [[CBAddressBarViewController alloc] initWithConversation:self.conversation];
	} else {
		self.addressBarController = [[CBAddressBarViewController alloc] init];
	}
	
	self.addressBarController.delegate = self;
	
	[self.sheetRootViewController addChildViewController:self.addressBarController];
	[self.sheetRootViewController.view addSubview:self.addressBarController.view];
	[self.addressBarController didMoveToParentViewController:self.sheetRootViewController];
	
	[self configureAddressbarLayoutConstraints];
	
	self.addressBarController.toField.textView.keyboardAppearance = self.textView.keyboardAppearance;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if(self.mode == ScheduleMode) {
		[self.buttonsToolbar setContentOffset:CGPointMake(CGRectGetWidth(self.buttonsToolbar.frame), 0.f) animated:YES];
		[self.scheduleButton startGlowing];
	}
    
    if([[CBSettingsSyncer valueForKey:@"recents"] boolValue]) {
        [self performSelector:@selector(acceptRecipientInput) withObject:nil afterDelay:.3f];
    }
}

- (CGSize)_intrinsicSheetSize
{
	CGSize size = [super _intrinsicSheetSize];
	size.height += CGRectGetHeight(self.addressBarController.toFieldContainerView.frame);
	
	return size;
}

- (void)configureAddressbarLayoutConstraints
{
	[self.sheetRootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.sheetRootViewController.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
	[self.sheetRootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.sheetRootViewController.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
	[self.sheetRootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.sheetRootViewController.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
	[self.sheetRootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.sheetRootViewController.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

- (void)recipientSelectionController:(CKComposeRecipientSelectionController*)controller didSelectConversation:(CKConversation*)conversation
{
	self.sheetRootViewController.tableView.hidden = NO;
}

- (void)recipientSelectionController:(id)arg1 textDidChange:(NSString*)text
{
	if(text.length > 0) {
		self.sheetRootViewController.tableView.hidden = YES;
	} else {
		self.sheetRootViewController.tableView.hidden = NO;
	}
}

- (void)recipientSelectionControllerReturnPressed:(id)arg1
{
	self.sheetRootViewController.tableView.hidden = NO;
}

- (void)recipientSelectionControllerDidChangeSize:(id)arg1
{
	
}

- (void)recipientSelectionControllerDidPushABViewController:(id)arg1
{
	
}

- (void)recipientSelectionControllerRequestDismissKeyboard:(id)arg1
{
	
}

- (void)recipientSelectionController:(id)arg1 didFinishAvailaiblityLookupForRecipient:(id)arg2
{
	
}

- (void)recipientSelectionControllerSearchListDidShowOrHide:(id)arg1
{
	
}

- (UIEdgeInsets)navigationBarInsetsForRecipientSelectionController:(CKComposeRecipientSelectionController*)controller
{
	return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (void)completeDismissal
{
	[super completeDismissal];
	
	if(self.addressBarController.toFieldIsFirstResponder) {
		[self.addressBarController.toField.textView resignFirstResponder];
	}
}

- (void)buttonTapped:(UIButton*)sender
{
	[super buttonTapped:sender];
	
	if([sender.titleLabel.text isEqualToString:COLUMBA_MESSAGES]) {
		CBConversationListController *conversationsVC = [[CBConversationListController alloc] init];
		conversationsVC.delegate = self;
		conversationsVC.preferredContentSize = CGSizeMake(self._intrinsicSheetSize.width, self._intrinsicSheetSize.height*1.3);
		
		[self.navigationController pushViewController:conversationsVC animated:YES];
	}
}

- (void)didSelectPost
{
	[super didSelectPost];
	
	if([self.navigationController.navigationBar.topItem.rightBarButtonItem.title isEqualToString:COLUMBA_SEND]) {
		if(self.conversation) {
			[CBChat sendTextMessage:self.textView.text toConversation:self.conversation attachments:self.pickedAttachments];
		} else {
			[CBChat sendTextMessage:self.textView.text toContacts:self.addressBarController.searchListController.enteredRecipients attachments:self.pickedAttachments];
		}
	}
}

- (void)recipientsChanged
{
	self.recipients = MSHookIvar<NSArray*>(self.addressBarController.searchListController, "_enteredRecipients");
	
	[super recipientsChanged];
	
	if(self.addressBarController.searchListController.enteredRecipients.count > 0) {
		MFModernComposeRecipientAtom *atom = MSHookIvar<NSMutableArray*>(self.addressBarController.toField, "_atomViews")[0];
		
		[self changeActionButtonColour:atom.titleLabel.textColor];
	}
}

- (void)finishedPickingMedia:(BOOL)sendImmediately
{
	if(sendImmediately) {
		if(self.recipients > 0 || self.conversation) {
			[self simulateSendAction];
		} else {
			[self acceptRecipientInput];
		}
	} else {
		[self acceptTextInput];
	}
}

- (void)viewController:(UIViewController*)viewController selectedConversation:(CKConversation*)conversation atIndexPath:(NSIndexPath*)indexPath
{
	[self.addressBarController.toField removeFromSuperview];
	
	[viewController.navigationController popViewControllerAnimated:YES];
	
	self.conversation = conversation;
	
	[self setupTitleView];
	[self performSelector:@selector(makeToolbarButtonsChecks) withObject:nil afterDelay:.1];
	
	if([self.conversation.sendingService isEqual:[IMService smsService]]) {
		[self performSelector:@selector(changeActionButtonColour:) withObject:CBColour.green afterDelay:.1];
	} else if([self.conversation.sendingService isEqual:[IMService iMessageService]]) {
		[self performSelector:@selector(changeActionButtonColour:) withObject:CBColour.blue afterDelay:.1];
	}
}

- (void)setupTitleView
{
	if(self.avatarView) {
		[self.avatarView removeFromSuperview];
		self.avatarView = nil;
	}
	
	self.avatarView = [[CKAvatarView alloc] init];
	self.avatarView.contacts = self.conversation.orderedContactsForAvatarView;
	self.avatarView.presentingViewController = self.addressBarController;
	
	[ColumbaUI removeAllConstraints:self.avatarView];
	[ColumbaUI makeAutoLayout:self.avatarView];
	
	if(!self.nameLabel) {
		self.nameLabel = [[UILabel alloc] init];
		self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		self.nameLabel.numberOfLines = 0;
		
		[ColumbaUI makeAutoLayout:self.nameLabel];
	}
	
	self.nameLabel.text = self.conversation.hasDisplayName ? self.conversation.displayName : self.conversation.name;
	
	if(!self.titleView) {
		self.titleView = [ColumbaUI autoLayoutView];
	}
	
	[self.titleView addSubview:self.avatarView];
	
	if(!self.titleViewConfigured) {
		self.titleViewConfigured = YES;
		self.addressBarController.backdropView.hidden = NO;
		
		[self.titleView addSubview:self.nameLabel];
		[self.addressBarController.toFieldContainerView addSubview:self.titleView];
		
		[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.addressBarController.toFieldContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
		[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.addressBarController.toFieldContainerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
		
		[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
		[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	}
	
	[self.avatarView.imageButton addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView.imageButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.avatarView.imageButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
	
	[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView.imageButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.addressBarController.toFieldContainerView attribute:NSLayoutAttributeHeight multiplier:1 constant:-2]];
	[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView.imageButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView.imageButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView.imageButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
	[self.addressBarController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView.imageButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeLeading multiplier:1 constant:-8]];
}

- (void)removeConversation
{
	self.conversation = nil;
	
	[self.avatarView removeFromSuperview];
	[self.nameLabel removeFromSuperview];
	[self.titleView removeFromSuperview];
	
	self.addressBarController.backdropView.hidden = YES;
	
	[self.addressBarController.toFieldContainerView addSubview:self.addressBarController.toField];
}

- (void)acceptRecipientInput
{
	[self.addressBarController.toField.textView becomeFirstResponder];
}

- (void)acceptTextInput
{
	[self.textView becomeFirstResponder];
}

@end
