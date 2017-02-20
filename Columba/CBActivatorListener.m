//
//  CBActivatorListener.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-16.
//
//

#import "../headers/headers.h"

#import "CBActivatorListener.h"
#import "CBComposeViewController.h"
#import "CBMessagingWindow.h"
#import "CBReplyWindowViewController.h"

@interface SBNotificationCenterController : NSObject

@property(getter=isVisible, nonatomic, readonly) BOOL visible;

+ (instancetype)sharedInstance;
- (void)dismissAnimated:(BOOL)arg1 completion:(void (^)())block;

@end

@interface CBActivatorListener ()

@property(nonatomic) CBMessagingWindowViewController *lastlyDismissed;
@property(nonatomic) CKImagePickerController *imagePicker;
@property(nonatomic) CBMessagingWindowViewController *messagingController;
@property(nonatomic) SBNotificationCenterController *notificationCenterController;

@end

@implementation CBActivatorListener

+ (instancetype)sharedInstance
{
	static CBActivatorListener *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
		sharedInstance.lockScreenManager = [objc_getClass("SBLockScreenManager") sharedInstance];
		sharedInstance.visible = NO;
	});

	return sharedInstance;
}

- (SBNotificationCenterController*)notificationCenterController
{
	if(!_notificationCenterController) {
		_notificationCenterController = [objc_getClass("SBNotificationCenterController") sharedInstance];
	}
	
	return _notificationCenterController;
}

- (void)initWindowIfNecessary
{
	if(!self.window) {
		self.window = [[UIWindow alloc] init];
		self.window.backgroundColor = [UIColor clearColor];
		self.window.windowLevel = UIWindowLevelStatusBar + 100.0;
	}
}

- (void)configureWindow
{
	self.window.frame = [UIScreen mainScreen].bounds;
	self.window.rootViewController = self.messagingController;
}

- (void)handleLockScreenPresentation
{
	if(self.notificationCenterController.isVisible) {
		[self.notificationCenterController dismissAnimated:YES completion:^{
			[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.messagingController animated:YES completion:nil];
		}];
	} else {
		[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.messagingController animated:YES completion:nil];
	}
}

- (void)presentQuickComposeWindow:(NSUInteger)mode
{
	self.messagingController = [[CBComposeViewController alloc] init];
	
	((CBComposeViewController*)self.messagingController).mode = mode;
	
	if(self.lockScreenManager.isUILocked) {
		[self handleLockScreenPresentation];
	} else {
		[self initWindowIfNecessary];
		[self configureWindow];
		
		[self.window makeKeyAndVisible];
	}
	
	self.visible = YES;
}

- (void)presentImagePickerController
{
	self.imagePicker = [[CKImagePickerController alloc] init];
	self.imagePicker.delegate = self.messagingController;
	
	self.window.rootViewController = self.imagePicker;
	
	[self.window makeKeyAndVisible];
}

- (void)presentCameraController
{
	self.imagePicker = [[CKImagePickerController alloc] init];
	self.imagePicker.delegate = self.messagingController;
	self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	self.window.rootViewController = self.imagePicker;
	
	[self.window makeKeyAndVisible];
}

- (void)dismissImagePickerController
{
	self.window.rootViewController = self.messagingController;
	
	[self.window makeKeyAndVisible];
}

- (void)presentQuickReplyWindowWithBulletin:(BBBulletin*)bulletin mode:(NSUInteger)mode attachments:(NSMutableArray*)attachments
{
	self.messagingController = [[CBReplyWindowViewController alloc] init];
	self.messagingController.pickedAttachments = attachments ? : [NSMutableArray array];
	
	((CBReplyWindowViewController*)self.messagingController).bulletin = bulletin;
	((CBReplyWindowViewController*)self.messagingController).mode = mode;
	
	if(self.lockScreenManager.isUILocked) {
		[self handleLockScreenPresentation];
	} else {
		[self initWindowIfNecessary];
		[self configureWindow];
		
		[self.window makeKeyAndVisible];
	}
	
	self.visible = YES;
}

- (void)activator:(LAActivator*)activator receiveEvent:(LAEvent*)event
{
	[self presentQuickComposeWindow:QuickComposeMode];
	[event setHandled:YES];
}

- (UIImage*)activator:(LAActivator*)activator requiresIconForListenerName:(NSString*)listenerName scale:(CGFloat)scale
{
	UIImage *image = nil;
	
	if([listenerName isEqualToString:@"Columba Compose"]) {
		NSString *name = [NSString stringWithFormat:@"/Library/Application Support/Columba/Resources.bundle/SettingsIcon@%dx.png", (int)scale];
		image = [UIImage imageWithContentsOfFile:name];
	}
	
	return image;
}

- (UIImage*)activator:(LAActivator*)activator requiresSmallIconForListenerName:(NSString*)listenerName scale:(CGFloat)scale
{
	UIImage *image = nil;
	
	if([listenerName isEqualToString:@"Columba Compose"]) {
		image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Columba/Resources.bundle/Icon-48x48.png"];
	}
	
	return image;
}

- (void)statusBarAction:(id)sender
{
	if(self.lastlyDismissed) {
		self.messagingController = self.lastlyDismissed;
		
		if(self.lockScreenManager.isUILocked) {
			[self handleLockScreenPresentation];
		} else {
			[self initWindowIfNecessary];
			[self configureWindow];
			
			[self.window makeKeyAndVisible];
		}
	} else {
		[self presentQuickComposeWindow:QuickComposeMode];
	}
}

- (void)dismissWindowIfPossible
{
	if(self.messagingController) {
		[self.messagingController cancel];
	}
}

- (void)dismissedWindow:(CBMessagingWindowViewController*)viewController
{
	self.lastlyDismissed = viewController;
}

@end
