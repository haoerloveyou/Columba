//
//  CBReplyWindowViewController.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-25.
//
//

#import <UIKit/UIKit.h>
#import "CBMessagingWindowViewController.h"

typedef enum : NSUInteger {
	NewNotificationMode,
	QuickReplyMode,
	Uninitialized,
} CBReplyWindowMode;

@interface CBReplyWindowViewController : CBMessagingWindowViewController

@property(nonatomic) BBBulletin *bulletin;
@property CBReplyWindowMode mode;

@end
