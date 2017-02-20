//
//  CBChat.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-19.
//
//

#import <Foundation/Foundation.h>

@interface CBChat : NSObject

+ (void)deleteMessageForBulletin:(BBBulletin*)bulletin;
+ (void)sendTextMessage:(NSString*)text toContacts:(NSArray*)contacts attachments:(NSArray*)attachments;
+ (void)sendTextMessage:(NSString*)text toConversation:(CKConversation*)conversation attachments:(NSArray*)attachments;
+ (CKConversation*)conversationFromBulletin:(BBBulletin*)bulletin;
+ (CKConversation*)conversationFromContacts:(NSArray*)contacts create:(BOOL)create;
+ (IMMessagePartChatItem*)chatItemFromBulletin:(BBBulletin*)bulletin;

@end
