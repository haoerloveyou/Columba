//
//  CBMessageScheduler.mm
//  
//
//  Created by Mohamed Marbouh on 2016-10-04.
//
//

#import "../headers/headers.h"

#import "CBMessageScheduler.h"

#import "CBChat.h"
#import "CBTimersRegistry.h"

@implementation CBMessageScheduler

+ (NSDictionary*)dictionaryFromRecipient:(MFComposeRecipient*)recipient
{
	return @{@"id": recipient.contact.identifier, @"address": recipient.address, @"kind": @(recipient.kind), @"sourceType": @(recipient.sourceType), @"displayString": recipient.displayString, @"abId": @(MSHookIvar<int>(recipient.contact, "_iOSLegacyIdentifier"))};
}

+ (MFComposeRecipient*)recipientFromDictionaryEntry:(NSDictionary*)dictionary
{
	CNContact *contact = [CNContact contactWithIdentifier:dictionary[@"id"]];
	MSHookIvar<int>(contact, "_iOSLegacyIdentifier") = [dictionary[@"abId"] intValue];
	
	MFComposeRecipient *recipient = [[MFComposeRecipient alloc] initWithContact:contact address:dictionary[@"address"] kind:[dictionary[@"kind"] unsignedLongLongValue]];
	recipient.contact = contact;
	recipient.displayString = dictionary[@"displayString"];
	recipient.sourceType = [dictionary[@"sourceType"] unsignedLongLongValue];
	
	return recipient;
}

+ (NSDictionary*)dictionaryFromMediaObject:(CKMediaObject*)object
{
	return @{@"data": object.data, @"UTIType": object.UTIType};
}

+ (CKMediaObject*)mediaObjectFromDictionaryEntry:(NSDictionary*)dictionary
{
	return [[CKMediaObjectManager sharedInstance] mediaObjectWithData:dictionary[@"data"] UTIType:dictionary[@"UTIType"] filename:nil transcoderUserInfo:nil];
}

+ (CKConversation*)conversationFromDictionaryEntry:(NSDictionary*)dictionary
{
	return [[CKConversationList sharedConversationList] conversationForExistingChatWithGUID:dictionary[@"conversation"]];
}

+ (void)scheduleMessage:(NSDictionary*)messageInfo
{
	PCPersistentTimer *timer = [[PCPersistentTimer alloc] initWithFireDate:messageInfo[@"date"] serviceIdentifier:@"com.mootjeuh.columba" target:self selector:@selector(handleTimer:) userInfo:messageInfo];
	
	[[CBTimersRegistry sharedInstance] scheduleTimer:timer];
}

+ (NSArray*)registeredMessages
{
	return [CBSettingsSyncer valueForKey:@"scheduledMessages"];
}

+ (void)handleTimer:(PCPersistentTimer*)timer
{
	NSDictionary *userInfo = MSHookIvar<id>(timer, "_userInfo");
	NSDate *now = [NSDate date];
	
	if([[NSCalendar currentCalendar] compareDate:now toDate:userInfo[@"date"] toUnitGranularity:NSCalendarUnitMinute] == NSOrderedSame) {
		CKConversation *conversation = nil;
		
		if([userInfo.allKeys containsObject:@"conversation"]) {
			conversation = [self conversationFromDictionaryEntry:userInfo];
		} else if([userInfo.allKeys containsObject:@"recipients"]) {
			NSMutableArray *recipients = [NSMutableArray array];
	
			for(NSDictionary *recipient in userInfo[@"recipients"]) {
				[recipients addObject:[self recipientFromDictionaryEntry:recipient]];
			}
			
			conversation = [CBChat conversationFromContacts:recipients create:YES];
		}
		
		if(conversation) {
			[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
				NSMutableArray *attachments = [NSMutableArray array];
				
				if([userInfo.allKeys containsObject:@"attachments"]) {
					for(NSDictionary *entry in userInfo[@"attachments"]) {
						[attachments addObject:[self mediaObjectFromDictionaryEntry:entry]];
					}
				}
				
				[CBChat sendTextMessage:userInfo[@"text"] toConversation:conversation attachments:attachments];
			}];
		}
	} else if([[NSCalendar currentCalendar] compareDate:now toDate:userInfo[@"date"] toUnitGranularity:NSCalendarUnitSecond] == NSOrderedAscending) {
		[timer scheduleInQueue:[PCPersistentTimer _backgroundUpdateQueue]];
	}
}

@end
