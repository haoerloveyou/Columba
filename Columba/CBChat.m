//
//  CBChat.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-19.
//
//

#import "../headers/headers.h"

#import "CBChat.h"

@interface IMPerson ()

- (BOOL)isEqualToIMPerson:(IMPerson*)person;

@end

@interface IMHandle ()

@property(setter=setIMPerson:, nonatomic, retain) IMPerson *person;

@end

@interface IMHandleRegistrar : NSObject

+ (instancetype)sharedInstance;
- (NSArray*)allIMHandles;

@end

@implementation CBChat

+ (CKConversation*)conversationFromBulletin:(BBBulletin*)bulletin
{
	CKConversation *result = nil;
	NSString *guid = nil;
	
	if([bulletin.context.allKeys containsObject:@"CKBBContextKeyChatGUIDs"]) {
		NSArray *GUIDs = [NSArray arrayWithArray:bulletin.context[@"CKBBContextKeyChatGUIDs"]];
		guid = GUIDs[0];
	} else if([bulletin.context.allKeys containsObject:@"AssistantContext"]) {
		NSDictionary *assistantContext = [NSDictionary dictionaryWithDictionary:bulletin.context[@"AssistantContext"]];
		if([assistantContext.allKeys containsObject:@"CKBBContextKeyChatGUIDs"]) {
			NSArray *GUIDs = [NSArray arrayWithArray:assistantContext[@"CKBBContextKeyChatGUIDs"]];
			guid = GUIDs[0];
		}
	}
	
	if(guid) {
		result = [[CKConversationList sharedConversationList] conversationForExistingChatWithGUID:guid];
	}
	
	return result;
}

+ (NSArray*)populateIMHandlesForIMPerson:(IMPerson*)person
{
	NSMutableArray *result = [NSMutableArray array];
	
	for(IMHandle *handle in [[IMHandleRegistrar sharedInstance] allIMHandles]) {
		if([handle.person isEqualToIMPerson:person]) {
			[result addObject:handle];
		}
	}
	
	return result;
}

+ (CKConversation*)conversationFromContacts:(NSArray*)contacts create:(BOOL)create
{
	NSMutableArray *handles = [NSMutableArray array];
	NSString *displayName = @"";
	
	for(MFComposeRecipient *recipient in contacts) {		
		IMPerson *person = [[IMPerson alloc] initWithABRecordID:recipient.contact.iOSLegacyIdentifier];
		
		if(contacts.count > 1) {
			if(displayName.length == 0) {
				displayName = person.displayName;
			} else {
				displayName = [displayName stringByAppendingString:[NSString stringWithFormat:@", %@", person.displayName]];
			}
		} else {
			displayName = person.displayName;
		}
		
		NSArray *contactHandles = [IMHandle imHandlesForIMPerson:person];
		NSMutableArray *temp = [NSMutableArray array];
		
		if(!contactHandles || contactHandles.count < 1) {
			contactHandles = [self populateIMHandlesForIMPerson:person];
		}
		
		for(IMHandle *contactHandle in contactHandles) {
			if([contactHandle.service isEqual:[IMService iMessageService]] || [contactHandle.service isEqual:[IMService smsService]]) {
				if([contactHandle.normalizedID containsString:recipient.normalizedAddress]) {
					[temp addObject:contactHandle];
				}
			}
		}
		
		if(temp.count >= 1) {
			[handles addObject:[IMHandle bestIMHandleInArray:temp]];
		}
	}
	
	return [[CKConversationList sharedConversationList] conversationForHandles:handles displayName:displayName joinedChatsOnly:NO create:create];
}

+ (IMMessagePartChatItem*)chatItemFromBulletin:(BBBulletin*)bulletin
{
	IMMessagePartChatItem *result = nil;
	NSString *guid = nil;
	CKConversation *conversation = [self conversationFromBulletin:bulletin];
	
	if([bulletin.context.allKeys containsObject:@"CKBBContextKeyMessageGUID"]) {
		guid = bulletin.context[@"CKBBContextKeyMessageGUID"];
	} else if([bulletin.context.allKeys containsObject:@"AssistantContext"]) {
		NSDictionary *assistantContext = [NSDictionary dictionaryWithDictionary:bulletin.context[@"AssistantContext"]];
		if([assistantContext.allKeys containsObject:@"CKBBContextKeyMessageGUID"]) {
			guid = assistantContext[@"CKBBContextKeyMessageGUID"];
		}
	}
	
	if(guid && conversation) {
		NSArray *chatItems = conversation.chat.chatItems;
		
		for(id item in [chatItems reverseObjectEnumerator]) {
			if([item respondsToSelector:@selector(message)]) {
				IMMessage *chatMessage = (IMMessage*)[item message];
				if([chatMessage.guid isEqualToString:guid]) {
					result = item;
					break;
				}
			}
		}
	}
	
	return result;
}

+ (void)sendTextMessage:(NSString*)text toContacts:(NSArray*)contacts attachments:(NSArray*)attachments
{
	CKConversation *conversation = [self conversationFromContacts:contacts create:YES];
	CKComposition *composition = [[CKComposition alloc] initWithText:[[NSAttributedString alloc] initWithString:text] subject:nil];
	
	if(attachments.count > 0) {
		composition = [composition compositionByAppendingMediaObjects:attachments];
	}
	
	id message = [conversation messageWithComposition:composition];
	
	[conversation sendMessage:message newComposition:YES];
}

+ (void)sendTextMessage:(NSString*)text toConversation:(CKConversation*)conversation attachments:(NSArray*)attachments
{
	CKComposition *composition = [[CKComposition alloc] initWithText:[[NSAttributedString alloc] initWithString:text] subject:nil];
	
	if(attachments.count > 0) {
		composition = [composition compositionByAppendingMediaObjects:attachments];
	}
	
	id message = [conversation messageWithComposition:composition];
	
	[conversation sendMessage:message newComposition:YES];
}

+ (void)deleteMessageForBulletin:(BBBulletin*)bulletin
{
	IMMessagePartChatItem *chatItem = [self chatItemFromBulletin:bulletin];
	CKConversation *conversation = [self conversationFromBulletin:bulletin];
	
	if(chatItem && conversation) {
		[conversation.chat deleteChatItems:@[chatItem]];
	}
}

@end
