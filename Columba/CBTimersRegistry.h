//
//  CBTimersRegistry.h
//  
//
//  Created by Mohamed Marbouh on 2016-10-06.
//
//

#import <Foundation/Foundation.h>

@interface CBTimersRegistry : NSObject

+ (instancetype)sharedInstance;
- (void)scheduleTimer:(PCPersistentTimer*)timer;
- (void)scheduleTimerForMessage:(NSDictionary*)message;
- (void)invalidateTimerForID:(NSString*)identifier;

@end
