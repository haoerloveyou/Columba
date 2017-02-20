@interface CKConversationList : NSObject

+ (instancetype)sharedConversationList;
- (CKConversation*)conversationForHandles:(NSArray*)handles displayName:(NSString*)name joinedChatsOnly:(BOOL)joinedChatsOnly create:(BOOL)create;
- (CKConversation*)conversationForExistingChatWithGUID:(NSString*)guid;

@end