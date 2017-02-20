//
//  CBTimersRegistry.m
//  
//
//  Created by Mohamed Marbouh on 2016-10-06.
//
//

#import "../headers/headers.h"

#import "CBTimersRegistry.h"

@interface CBTimersRegistry ()

@property(nonatomic) NSMutableDictionary *timers;

@end

@implementation CBTimersRegistry

+ (instancetype)sharedInstance
{
	static CBTimersRegistry *sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
		sharedInstance.timers = [NSMutableDictionary dictionary];
	});
	
	return sharedInstance;
}

- (void)scheduleTimer:(PCPersistentTimer*)timer
{
    if(timer.isValid) {
        [timer scheduleInQueue:[PCPersistentTimer _backgroundUpdateQueue]];
        
        NSString *key = [NSString stringWithFormat:@"%p", timer];
        
        self.timers[key] = timer;
    }
}

- (void)scheduleTimerForMessage:(NSDictionary*)message
{
	PCPersistentTimer *timer = [[PCPersistentTimer alloc] initWithFireDate:message[@"date"] serviceIdentifier:@"com.mootjeuh.columba" target:objc_getClass("CBMessageScheduler") selector:@selector(handleTimer:) userInfo:message];
	
	NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:message];
	temp[@"memAddress"] = [NSString stringWithFormat:@"%p", timer];
	
	[self scheduleTimer:timer];
	[self registerMessage:temp];
}

- (void)registerMessage:(NSDictionary*)messageInfo
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:[CBSettingsSyncer valueForKey:@"scheduledMessages"]];
	[array addObject:messageInfo];
	
	[CBSettingsSyncer setValue:array forKey:@"scheduledMessages"];
}

- (void)unregisterMessageForTimerID:(NSString*)identifier
{
	NSMutableArray *messages = [NSMutableArray arrayWithArray:[CBSettingsSyncer valueForKey:@"scheduledMessages"]];
	NSDictionary *message = nil;
	
	for(NSDictionary *item in messages) {
		if([item[@"memAddress"] isEqualToString:identifier]) {
			message = item;
			break;
		}
	}
	
	if(message) {
		[messages removeObject:message];
		[CBSettingsSyncer setValue:messages forKey:@"scheduledMessages"];
	}
}

- (void)invalidateTimerForID:(NSString*)identifier
{
	PCPersistentTimer *timer = self.timers[identifier];
	
	if(timer) {
		if([timer respondsToSelector:@selector(invalidate)]) {
			[timer invalidate];
		}
		
		[self.timers removeObjectForKey:identifier];
	}
}

@end
