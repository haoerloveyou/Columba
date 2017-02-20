//
//  CBComposeViewController.h
//
//  Created by Mohamed Marbouh on 2016-09-12.
//  Copyright © 2016 Mohamed Marbouh. All rights reserved.
//

#import <Social/Social.h>
#import "CBMessagingWindowViewController.h"

typedef enum : NSUInteger {
	QuickComposeMode,
	ScheduleMode,
} CBComposeWindowMode;

@interface CBComposeViewController : CBMessagingWindowViewController

@property CBComposeWindowMode mode;

- (void)removeConversation;

@end
