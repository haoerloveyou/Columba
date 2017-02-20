//
//  CBCommunicationsHandler.h
//  
//
//  Created by Mohamed Marbouh on 2016-10-04.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
	QuickComposeMode,
	ScheduleMode,
} CBComposeWindowMode;

@interface CBCommunicationsHandler : NSObject

+ (void)setupServer;
+ (void)requestSpringBoardRestart;
+ (void)requestQuickCompose:(CBComposeWindowMode)mode;
+ (void)requestTimerInvalidation:(NSDictionary*)timerInfo;
+ (void)requestTimerValidationForMessage:(NSDictionary*)message;

@end
