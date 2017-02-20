@class CKEntity, IMChat, IMService;

@interface CKConversation : NSObject

@property(nonatomic, retain) IMChat *chat;
@property(nonatomic, retain, readonly) IMService *sendingService;
@property (nonatomic,retain,readonly) NSString * name;
@property (nonatomic,readonly) BOOL hasDisplayName;
@property (assign,nonatomic) NSString * displayName;

+ (instancetype)newPendingConversation;
- (BOOL)_sms_canSendToRecipients:(NSArray*)recipients alertIfUnable:(BOOL)alert;
- (BOOL)_iMessage_canSendToRecipients:(NSArray*)recipients alertIfUnable:(BOOL)alert;
- (BOOL)canSendToRecipients:(NSArray*)recipients alertIfUnable:(BOOL)alert;
- (void)addRecipientHandles:(NSArray*)handles;
- (id)messageWithComposition:(CKComposition*)composition;
- (void)sendMessage:(id)message newComposition:(BOOL)isNew;
- (NSArray*)orderedContactsForAvatarView;
- (void)markAllMessagesAsRead;

@end
