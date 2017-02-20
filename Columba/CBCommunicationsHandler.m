//
//  CBCommunicationsHandler.m
//  
//
//  Created by Mohamed Marbouh on 2016-10-04.
//
//

#import "../headers/headers.h"

#import "CBCommunicationsHandler.h"
#import "CBTimersRegistry.h"

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface FBSystemService : NSObject

+ (instancetype)sharedInstance;
- (void)exitAndRelaunch:(BOOL)arg1;

@end

@interface CBCommunicationsHandler ()

+ (void)presentQuickCompose:(CBComposeWindowMode)mode;
+ (void)restartSpringBoard;
+ (void)invalidateTimer:(NSDictionary*)timerInfo;
+ (void)validateTimerForMessage:(NSDictionary*)message;

@end

static const CFStringRef restartName = CFSTR("CB_RestartSpringBoard");
static const CFStringRef qcName = CFSTR("CB_QuickCompose");
static const CFStringRef invalidateName = CFSTR("CB_InvalidateTimer");
static const CFStringRef validateName = CFSTR("CB_ValidateTimerForMessage");

static void Callback(CFNotificationCenterRef center,
					 void *observer,
					 CFStringRef name,
					 const void *object,
					 CFDictionaryRef userInfo)
{
	if(CFStringCompare(name, restartName, 0) == kCFCompareEqualTo) {
		[CBCommunicationsHandler restartSpringBoard];
	} else if(CFStringCompare(name, qcName, 0) == kCFCompareEqualTo) {
		[CBCommunicationsHandler presentQuickCompose:[((__bridge NSDictionary*)userInfo)[@"mode"] unsignedLongValue]];
	} else if(CFStringCompare(name, invalidateName, 0) == kCFCompareEqualTo) {
		[CBCommunicationsHandler invalidateTimer:(__bridge NSDictionary*)userInfo];
	} else if(CFStringCompare(name, validateName, 0) == kCFCompareEqualTo) {
		[CBCommunicationsHandler validateTimerForMessage:(__bridge NSDictionary*)userInfo];
	}
}

@implementation CBCommunicationsHandler

+ (void)setupServer
{
	CFNotificationCenterRef distributedCentre =	CFNotificationCenterGetDistributedCenter();
	CFNotificationSuspensionBehavior behaviour = CFNotificationSuspensionBehaviorDeliverImmediately;
	
	CFNotificationCenterAddObserver(distributedCentre, NULL, Callback, restartName, NULL, behaviour);
	CFNotificationCenterAddObserver(distributedCentre, NULL, Callback, qcName, NULL, behaviour);
	CFNotificationCenterAddObserver(distributedCentre, NULL, Callback, invalidateName, NULL, behaviour);
	CFNotificationCenterAddObserver(distributedCentre, NULL, Callback, validateName, NULL, behaviour);
}

+ (void)requestSpringBoardRestart
{
	CFNotificationCenterRef distributedCenter =
	CFNotificationCenterGetDistributedCenter();
	
	CFNotificationCenterPostNotification(distributedCenter,
										 restartName,
										 NULL,
										 NULL,
										 true);
}

+ (void)requestQuickCompose:(CBComposeWindowMode)mode
{
	CFNotificationCenterRef distributedCenter =
	CFNotificationCenterGetDistributedCenter();
	
	CFNotificationCenterPostNotification(distributedCenter,
										 qcName,
										 NULL,
										 (CFDictionaryRef)@{@"mode": @(mode)},
										 true);
}

+ (void)requestTimerInvalidation:(NSDictionary*)timerInfo
{
	CFNotificationCenterRef distributedCenter =
	CFNotificationCenterGetDistributedCenter();
	
	CFNotificationCenterPostNotification(distributedCenter,
										 invalidateName,
										 NULL,
										 (CFDictionaryRef)timerInfo,
										 true);
}

+ (void)requestTimerValidationForMessage:(NSDictionary*)message
{
	CFNotificationCenterRef distributedCenter =
	CFNotificationCenterGetDistributedCenter();
	
	CFNotificationCenterPostNotification(distributedCenter,
										 validateName,
										 NULL,
										 (CFDictionaryRef)message,
										 true);
}

+ (void)restartSpringBoard
{
	[[objc_getClass("FBSystemService") sharedInstance] exitAndRelaunch:YES];
}

+ (void)presentQuickCompose:(CBComposeWindowMode)mode
{
	[[objc_getClass("CBActivatorListener") sharedInstance] presentQuickComposeWindow:mode];
}

+ (void)invalidateTimer:(NSDictionary*)timerInfo
{
	[[objc_getClass("CBTimersRegistry") sharedInstance] invalidateTimerForID:timerInfo[@"id"]];
}

+ (void)validateTimerForMessage:(NSDictionary*)message
{
	[[objc_getClass("CBTimersRegistry") sharedInstance] scheduleTimerForMessage:message];
}

@end
