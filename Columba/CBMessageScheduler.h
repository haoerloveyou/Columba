//
//  CBMessageScheduler.h
//  
//
//  Created by Mohamed Marbouh on 2016-10-04.
//
//

#import <Foundation/Foundation.h>

@class MFComposeRecipient, CKMediaObject;

@interface CBMessageScheduler : NSObject

+ (NSDictionary*)dictionaryFromRecipient:(MFComposeRecipient*)recipient;
+ (NSDictionary*)dictionaryFromMediaObject:(CKMediaObject*)object;
+ (void)scheduleMessage:(NSDictionary*)messageInfo;
+ (NSArray*)registeredMessages;

@end
