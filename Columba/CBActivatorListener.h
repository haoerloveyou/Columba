//
//  CBActivatorListener.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-16.
//
//

#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>

@class BBBulletin, SBLockScreenManager, CBMessagingWindowViewController;

@interface CBActivatorListener : NSObject <LAListener>

@property(weak) SBLockScreenManager *lockScreenManager;
@property(getter=isVisible, nonatomic) BOOL visible;
@property(nonatomic) UIWindow *window;

+ (instancetype)sharedInstance;
- (void)presentQuickComposeWindow:(NSUInteger)mode;
- (void)presentQuickReplyWindowWithBulletin:(BBBulletin*)bulletin mode:(NSUInteger)mode attachments:(NSArray*)attachments;
- (void)dismissWindowIfPossible;
- (void)dismissedWindow:(CBMessagingWindowViewController*)viewController;

@end
