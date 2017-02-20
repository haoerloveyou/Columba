//
//  CBMessagingWindowViewController.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-23.
//
//

#import "../headers/headers.h"

#import "CBMessagingWindowViewController.h"

#import "CBChat.h"
#import "CBChatTranscriptViewController.h"
#import "CBColour.h"
#import "CBComposeViewController.h"
#import "CBMessageScheduler.h"
#import "CBReplyWindowViewController.h"
#import "CBTemplatesTableViewController.h"
#import "CBTimersRegistry.h"
#import "CBSocialMediator.h"

@interface CBMessagingWindowViewController () <CBTemplatesTableViewControllerDelegate>

@property(weak) UIButton *callButton;
@property(weak) UIButton *historyButton;

@property(nonatomic) NSArray *configItems;
@property(nonatomic) UIDatePicker *datePicker;
@property(nonatomic) UIView *tapView;

@end

@interface CKConversation (Columba)

@property(nonatomic, retain) NSArray *recipients;
@property(nonatomic, retain, readonly) CKEntity *recipient;

@end

@interface IMChat ()

@property(nonatomic, readonly) NSArray *participants;

@end

@interface IMHandle ()

@property(nonatomic, retain, readonly) NSString *firstName;
@property(nonatomic, retain, readonly) NSString *nickname;
@property(nonatomic, readonly) BOOL isSystemUser;

@end

@implementation CBMessagingWindowViewController

- (instancetype)init
{
	if((self = [super init])) {
		self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
		self.pickedAttachments = [NSMutableArray array];
		self.shouldShowOSK = YES;
		
		SLComposeSheetConfigurationItem *toolbarItem = [[SLComposeSheetConfigurationItem alloc] init];
		toolbarItem.title = @"toolbar";
		
		self.configItems = @[toolbarItem];
		
		checkForPayment(^(BOOL paid) {
			if(!paid) {
				SLComposeSheetConfigurationItem *adItem = [[SLComposeSheetConfigurationItem alloc] init];
				adItem.title = @"ad";
				
				self.configItems = @[adItem, toolbarItem];
			}
		});
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	checkForPayment(^(BOOL isOK) {
		if(!isOK) {
			[CBSocialMediator sharedInstance].viewController = self;
			[[CBSocialMediator sharedInstance] viewDidLoad];
		}
	});
	
	self.navigationController.navigationBar.topItem.rightBarButtonItem.title = COLUMBA_SEND;
	self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = NO;
	
	self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	
	if([[CBSettingsSyncer valueForKey:@"grayscaleOSK"] boolValue]) {
		self.textView.keyboardAppearance = UIKeyboardAppearanceDark;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[CBActivatorListener sharedInstance].visible = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	for(UITableViewCell *cell in self.sheetRootViewController.tableView.visibleCells) {
		for(id view in cell.subviews) {
			if([view isKindOfClass:CBButtonsToolbar.class]) {
				self.buttonsToolbar = view;
				break;
			}
		}
	}
	
	[self loadToolbarButtonsIfPossible];
	
	[CBActivatorListener sharedInstance].visible = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[CBActivatorListener sharedInstance].visible = NO;
}

- (void)cancel
{
	[super cancel];
	
	[CBActivatorListener sharedInstance].visible = NO;
}

- (UIView*)loadPreviewView
{
	if(!self.previewsView) {
		self.previewsView = [[CBMessagingWindowPreviewsView alloc] init];
	}
	
	return self.previewsView;
}

- (void)loadToolbarButtonsIfPossible
{
	if(self.buttonsToolbar) {
		self.attachmentsButton = [self.buttonsToolbar buttonWithTitle:COLUMBA_STRING(@"CB.attachments", @"Attachments")];
		self.attachmentsButton.enabled = YES;
		
		self.callButton = [self.buttonsToolbar buttonWithTitle:COLUMBA_CALL];
		self.callButton.enabled = NO;
		
		self.historyButton = [self.buttonsToolbar buttonWithTitle:COLUMBA_HISTORY];
		self.historyButton.enabled = NO;
		
		self.scheduleButton = [self.buttonsToolbar buttonWithTitle:COLUMBA_STRING(@"CB.schedule", @"Schedule")];
		self.scheduleButton.enabled = NO;
		
		self.templatesButton = [self.buttonsToolbar buttonWithTitle:COLUMBA_TEMPLATES];
		self.templatesButton.enabled = [[CBSettingsSyncer valueForKey:@"templates"] count] > 0;
		
		[self makeToolbarButtonsChecks];
	}
}

- (void)showKeyboardAnimated:(BOOL)animated
{
	if(self.shouldShowOSK) {
		[super showKeyboardAnimated:animated];
	} else {
		if(!self.wasPresented) {
			[self _presentSheet];
		}
	}
}

- (NSArray*)configurationItems
{
	return self.configItems;
}

- (void)completeDismissal
{	
	[CBActivatorListener sharedInstance].window.frame = CGRectZero;
	
	if([CBActivatorListener sharedInstance].lockScreenManager.isUILocked) {
		[self dismissViewControllerAnimated:NO completion:nil];
	}
}

- (void)didSelectCancel
{
	[self completeDismissal];
	[super didSelectCancel];
}

- (void)didSelectPost
{
	[self completeDismissal];
	[super didSelectPost];
	
	if([self.navigationController.navigationBar.topItem.rightBarButtonItem.title isEqualToString:COLUMBA_STRING(@"CB.schedule", @"Schedule")]) {
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:@{@"text": self.textView.text}];
		
		if(self.recipients.count > 0) {
			NSMutableArray *recipients = [NSMutableArray array];
			
			for(MFComposeRecipient *obj in self.recipients) {
				[recipients addObject:[CBMessageScheduler dictionaryFromRecipient:obj]];
			}
			
			info[@"recipients"] = recipients;
		}
		
		if(self.conversation) {
			info[@"conversation"] = self.conversation.chat.guid;
			
			if(self.conversation.hasDisplayName) {
				info[@"displayName"] = self.conversation.displayName;
			} else {
				info[@"displayName"] = self.conversation.name;
			}
		}
		
		info[@"date"] = self.datePicker.date;
		
		if(self.pickedAttachments.count > 0) {
			NSMutableArray *array = [NSMutableArray array];
			
			for(CKMediaObject *object in self.pickedAttachments) {
				[array addObject:[CBMessageScheduler dictionaryFromMediaObject:object]];
			}
			
			info[@"attachments"] = array;
		}
		
		[[CBTimersRegistry sharedInstance] scheduleTimerForMessage:info];
	}
}

- (void)textViewDidChange:(UITextView*)textView
{
	[self makeToolbarButtonsChecks];
}

- (void)cancelButtonTapped:(id)arg1
{
	if(self.textView.inputView) {
		[self switchToNormalOSK];
	} else {
		[super cancelButtonTapped:arg1];
	}
	
	[CBActivatorListener sharedInstance].visible = NO;
}

- (void)postButtonTapped:(id)arg1
{
	[super postButtonTapped:arg1];
	
	[CBActivatorListener sharedInstance].visible = NO;
}

- (void)switchToDatePicker
{
	[self.textView resignFirstResponder];
	
	self.datePicker = [[UIDatePicker alloc] init];
	self.datePicker.minimumDate = [NSDate date];
	
	self.textView.inputView = self.datePicker;
	self.navigationController.navigationBar.topItem.rightBarButtonItem.title = COLUMBA_STRING(@"CB.schedule", @"Schedule");

	[self.textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.3];
	
	self.tapView = [[UIView alloc] init];
	self.tapView.frame = self.sheetRootViewController.contentView.frame;
	
	[self.tapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchToNormalOSK)]];
	[self.sheetRootViewController.view addSubview:self.tapView];
}

- (void)switchToNormalOSK
{
	[self.textView resignFirstResponder];
	
	self.navigationController.navigationBar.topItem.rightBarButtonItem.title = COLUMBA_SEND;
	self.textView.inputView = nil;
	
	[self.textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.3];
	
	[self.tapView removeFromSuperview];
}

- (void)buttonTapped:(UIButton*)sender
{
	if([sender.titleLabel.text isEqualToString:COLUMBA_HISTORY]) {
		CKConversation *convo = [CBChat conversationFromContacts:self.recipients create:NO] ? : self.conversation;
		CBChatTranscriptViewController *transcript = [[CBChatTranscriptViewController alloc] initWithConversation:convo balloonMaxWidth:CGRectGetWidth(self.sheetRootViewController.view.frame)-30 marginInsets:UIEdgeInsetsMake(0, 5, 5, 5)];
		transcript.preferredContentSize = CGSizeMake(self._intrinsicSheetSize.width, self._intrinsicSheetSize.height*1.3);
		
		[self.navigationController pushViewController:transcript animated:YES];
	} else if([sender.titleLabel.text isEqualToString:COLUMBA_TEMPLATES]) {
		CBTemplatesTableViewController *templatesVC = [[CBTemplatesTableViewController alloc] init];
		templatesVC.delegate = self;
		
		if([[CBSettingsSyncer valueForKey:@"templates"] count] > 3) {
			templatesVC.preferredContentSize = CGSizeMake(self._intrinsicSheetSize.width, self._intrinsicSheetSize.height*1.3);
		}
		
		[self.navigationController pushViewController:templatesVC animated:YES];
	} else if([sender.titleLabel.text isEqualToString:COLUMBA_CALL]) {
		if(self.recipients.count == 1) {
			NSString *urlString = [NSString stringWithFormat:@"tel:%@", [self.recipients[0] normalizedAddress]];
			
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
		} else if(self.recipients.count > 1) {
			[self showCallChoiceSheet];
		} else if(self.conversation) {
			[self showCallChoiceSheet:self.conversation.chat.participants handles:YES];
		}
	} else if([sender.titleLabel.text isEqualToString:COLUMBA_STRING(@"CB.schedule", @"Schedule")]) {
		if(self.textView.inputView) {
			[self switchToNormalOSK];
		} else {
			[self switchToDatePicker];
		}
	} else if([sender.titleLabel.text isEqualToString:COLUMBA_STRING(@"CB.attachments", @"Attachments")]) {
		CKPhotoPickerController *picker = [[CKPhotoPickerController alloc] init];
		picker.delegate = self;
		
		if([CBActivatorListener sharedInstance].lockScreenManager.isUILocked) {
			picker.bottomAlertAction.enabled = NO;
			picker.topAlertAction.enabled = NO;
		}
		
		[self presentViewController:picker animated:YES completion:^{
			self.shouldShowOSK = NO;
			[self hideKeyboardAnimated:NO];
		}];
	} else if([sender.titleLabel.text isEqualToString:COLUMBA_OPEN]) {
		[super cancelButtonTapped:self.navigationController.navigationBar.topItem.leftBarButtonItem];
		
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:@{@"text": self.textView.text}];
		
		if(self.conversation) {
			info[@"conversation"] = self.conversation.chat.guid;
		} else if(self.recipients.count > 0) {
			info[@"recipients"] = [NSMutableArray array];
			
			for(MFComposeRecipient *recipient in self.recipients) {
				[info[@"recipients"] addObject:[CBMessageScheduler dictionaryFromRecipient:recipient]];
			}
		}
		
		NSString *string = [NSString stringWithFormat:@"sms://columba/%@", info];
		NSURL *url = [NSURL URLWithString:[string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
		
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)viewController:(UIViewController*)viewController selectedTemplate:(NSString*)templateText atIndexPath:(NSIndexPath*)indexPath
{
	[viewController.navigationController popViewControllerAnimated:YES];
	
	self.textView.text = [self.textView.text stringByAppendingString:templateText];
}

- (NSArray*)supportedMediaTypesForPhotoPicker:(CKPhotoPickerController*)viewController
{
	return @[@"public.movie", @"public.image"];
}

- (void)photoPickerController:(CKPhotoPickerController*)viewController requestsSendAssets:(NSArray*)assets sendImmediately:(BOOL)sendImmediately
{
	for(CKPhotoPickerItemForSending *item in assets) {
		if(item.localURL) {
			CKMediaObject *object = [[CKMediaObjectManager sharedInstance] mediaObjectWithFileURL:item.localURL filename:nil transcoderUserInfo:item.isVideo ? @{@"AVTranscodeAssetURI": item.localURL} : nil];
			
			[self.pickedAttachments addObject:object];
		}
	}
	
	[self.previewsView messagingViewController:self processItems:assets completion:^{
		[self finishedPickingMedia:sendImmediately];
	}];
}

- (void)photoPickerControllerRequestPresentPhotoLibrary:(CKPhotoPickerController*)viewController
{
	[[CBActivatorListener sharedInstance] performSelector:@selector(presentImagePickerController) withObject:nil afterDelay:0];
}

- (void)photoPickerControllerRequestPresentCamera:(CKPhotoPickerController*)viewController
{
	[[CBActivatorListener sharedInstance] performSelector:@selector(presentCameraController) withObject:nil afterDelay:0];
}

- (void)photoPickerControllerWillCancel:(CKPhotoPickerController*)viewController
{
	
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString*,id>*)info
{
	[[CBActivatorListener sharedInstance] performSelector:@selector(dismissImagePickerController) withObject:nil afterDelay:0];
	
	CKMediaObject *mediaObject = [[CKMediaObjectManager sharedInstance] mediaObjectWithData:UIImageJPEGRepresentation(info[@"UIImagePickerControllerOriginalImage"], 1)
																					UTIType:@"public.jpeg"
																				   filename:nil
																		 transcoderUserInfo:nil];
	
	MSHookIvar<UIImage*>(mediaObject, "_thumbnail") = info[@"UIImagePickerControllerOriginalImage"];
	
	[self performBlock:^{
		[self.pickedAttachments addObject:mediaObject];
		[self.previewsView messagingViewController:self processItems:@[mediaObject] completion:^{
			[self finishedPickingMedia:NO];
		}];
	} afterDelay:.3];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[[CBActivatorListener sharedInstance] performSelector:@selector(dismissImagePickerController) withObject:nil afterDelay:0];
}

- (void)makeToolbarButtonsChecks
{
	CKConversation *convo = nil;
 
	if(self.recipients && self.recipients.count >= 1) {
		convo = [CBChat conversationFromContacts:self.recipients create:NO];
	} else {
		convo = self.conversation;
	}
	
	if(convo == nil || convo.chat.chatItems.count == 0) {
		self.historyButton.enabled = NO;
	} else if(convo.chat.chatItems.count > 0) {
		self.historyButton.enabled = YES;
	}
	
	if((self.textView.text.length > 0 || self.pickedAttachments.count > 0) && (self.recipients.count > 0 || convo != nil)) {		
		self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = YES;
		self.scheduleButton.enabled = YES;
	} else {
		self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = NO;
		self.scheduleButton.enabled = NO;
	}
	
	self.callButton.enabled = self.recipients.count >= 1 || convo != nil;
}

- (void)recipientsChanged
{
	[self makeToolbarButtonsChecks];
}

- (void)showCallChoiceSheet:(NSArray*)recipients handles:(BOOL)flag
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
 
	if(flag) {
		for(IMHandle *handle in recipients) {
			NSString *title = handle.nickname.length > 0 ? handle.nickname : handle.firstName;
			UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				NSString *urlString = [NSString stringWithFormat:@"tel:%@", handle.normalizedID];
				
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
			}];
			
			[alert addAction:action];
		}
	} else {
		for(MFComposeRecipient *recipient in recipients) {
			NSString *title = recipient.contact.nickname.length > 0 ? recipient.contact.nickname : recipient.contact.givenName;
			UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				NSString *urlString = [NSString stringWithFormat:@"tel:%@", recipient.normalizedAddress];
				
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
			}];
			
			[alert addAction:action];
		}
	}
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:COLUMBA_CANCEL style:UIAlertActionStyleCancel handler:nil];
	[alert addAction:cancelAction];
	
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)showCallChoiceSheet
{
	[self showCallChoiceSheet:self.recipients handles:NO];
}

- (void)setConversation:(CKConversation*)conversation
{
	_conversation = conversation;
	
	[self makeToolbarButtonsChecks];
}

- (void)changeActionButtonColour:(UIColor*)colour
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self.navigationController.navigationBar.topItem.rightBarButtonItem titleTextAttributesForState:UIControlStateNormal]];
	
	attributes[NSForegroundColorAttributeName] = colour;
	
	[self.navigationController.navigationBar.topItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
	
	attributes = [NSMutableDictionary dictionaryWithDictionary:[self.navigationController.navigationBar.topItem.rightBarButtonItem titleTextAttributesForState:UIControlStateDisabled]];
	attributes[NSForegroundColorAttributeName] = CBColour.grey;
	
	[self.navigationController.navigationBar.topItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
}

- (void)finishedPickingMedia:(BOOL)sendImmediately
{
	[self makeToolbarButtonsChecks];
}

- (void)simulateSendAction
{
	[self postButtonTapped:self.navigationController.navigationBar.topItem.rightBarButtonItem];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
	[self performSelector:@selector(performBlock:) withObject:block afterDelay:delay];
}

- (void)performBlock:(void (^)(void))block
{
	block();
}

@end
