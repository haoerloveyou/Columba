@class CKConversation;

@protocol CKComposeRecipientSelectionControllerDelegate <NSObject, CKRecipientSelectionControllerDelegate>

- (void)recipientSelectionController:(id)controller didSelectConversation:(CKConversation*)conversation;

@end

@interface CKComposeRecipientSelectionController : CKRecipientSelectionController

@property (assign,nonatomic) id<CKComposeRecipientSelectionControllerDelegate> delegate;

@end