//
//  CBReplyWindowViewController.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-25.
//
//

#import "../headers/headers.h"

#import "CBReplyWindowViewController.h"

#import "CBChat.h"
#import "CBColour.h"
#import "CBReplyNotificationContainerView.h"
#import "CBSeparatorLine.h"

#import "../headers/LSStatusBarItem.h"

@interface CBReplyWindowViewController ()

@property(nonatomic) CBReplyNotificationContainerView *notificationView;
@property(nonatomic) LSStatusBarItem *statusBarItem;
@property(nonatomic) CBSeparatorLine *separatorLine;
@property(nonatomic) NSLayoutConstraint *heightConstraint;

@property BOOL addedHeightConstraint;
@property CGFloat oskY;

@end

@implementation CBReplyWindowViewController

- (instancetype)init
{
	if((self = [super init])) {
		self.addedHeightConstraint = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleOSK:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if(!self.notificationView) {
		self.notificationView = [[CBReplyNotificationContainerView alloc] initWithConversation:self.conversation bulletin:self.bulletin];
		
		[self.sheetRootViewController.view addSubview:self.notificationView];
	}
	
	if(self.bulletin.attachments) {
		self.notificationView.summaryText.text = [NSString stringWithFormat:COLUMBA_STRING(@"1_ATTACHMENT", @"%@ Attachments"), @(1+self.bulletin.attachments.numberOfAdditionalAttachments)];
		self.notificationView.summaryText.textColor = UIColor.grayColor;
	}
	
	[self configureViewForMode];
	[self configureNotificationViewLayoutConstraints];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if(self.mode == QuickReplyMode && self.pickedAttachments.count > 0) {
		[self.previewsView messagingViewController:self processItems:self.pickedAttachments completion:nil];
	}
}

- (void)configureViewForMode
{
	if(self.mode == QuickReplyMode) {
		self.shouldShowOSK = YES;
		
		self.navigationController.navigationBar.topItem.rightBarButtonItem.title = COLUMBA_SEND;
		
		if(![CBSeparatorLine isWithinViews:self.sheetRootViewController.tableView.subviews]) {
			self.separatorLine = [[CBSeparatorLine alloc] initForTableView:self.sheetRootViewController.tableView];
			
			[self.sheetRootViewController.tableView addSubview:self.separatorLine];
		}
	} else if(self.mode == NewNotificationMode) {
		self.shouldShowOSK = NO;
		
		self.navigationController.navigationBar.topItem.leftBarButtonItem.title = COLUMBA_DISMISS;
		self.navigationController.navigationBar.topItem.rightBarButtonItem.title = COLUMBA_REPLY.localizedCapitalizedString;
	}
	
	if([self.conversation.sendingService isEqual:[IMService smsService]]) {
		[self changeActionButtonColour:CBColour.green];
	}
}

- (void)makeToolbarButtonsChecks
{
	[super makeToolbarButtonsChecks];
	
	if(self.mode == NewNotificationMode) {
		self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = YES;
		self.attachmentsButton.enabled = NO;
		self.templatesButton.enabled = NO;
	}
}

- (CGSize)_intrinsicSheetSize
{
	CGSize size = [super _intrinsicSheetSize];
	
	if(self.mode == QuickReplyMode) {
		if(self.oskY > 0) {			
			CGFloat height = [self.notificationView sizeForMessageInBounds:CGSizeMake(size.width, CGFLOAT_MAX)].height;
			CGFloat potentialHeight = size.height+height;
			CGFloat difference = potentialHeight-self.oskY;
			
			if(difference > 0) {
				size.height += height-difference-60;
			} else {
				size.height += height;
			}
		}
	} else if(self.mode == NewNotificationMode) {
		CGFloat contentHeight = CGRectGetHeight(self.sheetRootViewController.contentView.frame);
		CGFloat messageHeight = [self.notificationView sizeForMessageInBounds:CGSizeMake(size.width, CGFLOAT_MAX)].height;
		CGFloat difference = messageHeight-contentHeight;
		
		if(difference > 0) {
			size.height += difference;
		}
	}
	
	return size;
}

- (void)didSelectCancel
{
	[super didSelectCancel];
	
/*	if ([Columba isLibStatusBarInstalled]) {
		[Columba loadLibStatusBar];
		
		self.statusBarItem = [[objc_getClass("LSStatusBarItem") alloc] initWithIdentifier:@"com.mootjeuh.columba" alignment:StatusBarAlignmentRight];
		self.statusBarItem.imageName = @"Columba";
		self.statusBarItem.visible = YES;
		
		[self.statusBarItem addTouchDelegate:[CBActivatorListener sharedInstance]];
		[self.statusBarItem update];
		[[CBActivatorListener sharedInstance] dismissedWindow:self];
	}*/
}

- (void)didSelectPost
{
	[super didSelectPost];
	
	if([self.navigationController.navigationBar.topItem.rightBarButtonItem.title isEqualToString:COLUMBA_SEND]) {
		[self.conversation markAllMessagesAsRead];
		[CBChat sendTextMessage:self.textView.text toConversation:self.conversation attachments:self.pickedAttachments];
	}
}

- (void)setBulletin:(BBBulletin*)bulletin
{
	_bulletin = bulletin;
	
	self.conversation = [CBChat conversationFromBulletin:bulletin];
}

- (void)configureNotificationViewLayoutConstraints
{
	[self.sheetRootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.notificationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.sheetRootViewController.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
	[self.sheetRootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.notificationView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.sheetRootViewController.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
	[self.sheetRootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.notificationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.sheetRootViewController.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
	
	if(self.mode == NewNotificationMode) {
		UITableViewCell *cell = [self.sheetRootViewController.tableView.dataSource tableView:self.sheetRootViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		CGFloat constant = /*CGRectGetHeight(self.sheetRootViewController.CB_pageControl.frame)*/10+CGRectGetHeight(cell.frame)*self.configurationItems.count;
		
		self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.notificationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.sheetRootViewController.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-constant];
	} else if(self.mode == QuickReplyMode) {
		self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.sheetRootViewController.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.notificationView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
	}
	
	if(!self.addedHeightConstraint) {
		self.addedHeightConstraint = YES;
		[self.sheetRootViewController.view addConstraint:self.heightConstraint];
	}
}

- (id)presentingViewControllerForAvatarView:(id)arg1
{
	return self;
}

- (BOOL)avatarView:(id)arg1 shouldShowContact:(id)arg2
{
	return YES;
}

- (void)buttonTapped:(UIButton*)sender
{
	[super buttonTapped:sender];
	
	if([sender.titleLabel.text isEqualToString:COLUMBA_DELETE]) {
		[CBChat deleteMessageForBulletin:self.bulletin];
		[self cancel];
	} else if([sender.titleLabel.text isEqualToString:COLUMBA_STRING(@"CB.schedule", @"Schedule")]) {
		if(self.mode == NewNotificationMode) {
			[self switchToQuickReplyMode];
		}
	}
}

- (void)switchToQuickReplyMode
{
	[[CBActivatorListener sharedInstance] presentQuickReplyWindowWithBulletin:self.bulletin mode:QuickReplyMode attachments:self.pickedAttachments];
}

- (void)postButtonTapped:(id)arg1
{
	if(self.mode == QuickReplyMode) {
		[super postButtonTapped:arg1];
	} else if(self.mode == NewNotificationMode) {
		[self switchToQuickReplyMode];
	}
}

- (void)finishedPickingMedia:(BOOL)sendImmediately
{
	if(sendImmediately) {
		if(self.mode == QuickReplyMode) {
			[self simulateSendAction];
		} else if(self.mode == NewNotificationMode) {
			[self switchToQuickReplyMode];
		}
	} else {
		if(self.mode == QuickReplyMode) {
			[self.textView becomeFirstResponder];
		} else if(self.mode == NewNotificationMode) {
			[self switchToQuickReplyMode];
		}
	}
}

- (void)handleOSK:(NSNotification*)notification
{
	CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	self.oskY = CGRectGetMinY(keyboardFrame);
}

@end
