@class CKComposeRecipientView, CKConversation;

@protocol CKRecipientSelectionControllerDelegate <NSObject>

- (void)recipientSelectionController:(id)arg1 textDidChange:(id)arg2;
- (void)recipientSelectionControllerReturnPressed:(id)arg1;
- (void)recipientSelectionControllerDidChangeSize:(id)arg1;
- (void)recipientSelectionControllerDidPushABViewController:(id)arg1;
- (void)recipientSelectionControllerRequestDismissKeyboard:(id)arg1;
- (void)recipientSelectionController:(id)arg1 didFinishAvailaiblityLookupForRecipient:(id)arg2;
- (void)recipientSelectionControllerSearchListDidShowOrHide:(id)arg1;
- (UIEdgeInsets)navigationBarInsetsForRecipientSelectionController:(id)arg1;

@end

@interface CKRecipientSelectionController : UIViewController

@property(nonatomic, retain) CKConversation *conversation;
@property(assign, getter=isPeoplePickerHidden, nonatomic) BOOL peoplePickerHidden;
@property(nonatomic, retain) CKRecipientSearchListController *searchListController;
@property(nonatomic, retain) CKComposeRecipientView *toField;
@property (nonatomic,retain) UIView * toFieldContainerView;
@property(nonatomic, retain) UIScrollView *toFieldScrollingView;
@property (nonatomic,readonly) BOOL toFieldIsFirstResponder;

- (instancetype)initWithConversation:(CKConversation*)conversation;

- (void)recipientViewDidBecomeFirstResponder:(id)arg1;
- (void)recipientViewDidResignFirstResponder:(id)arg1;
- (void)composeRecipientView:(id)arg1 didFinishEnteringAddress:(id)arg2;
- (void)addRecipient:(id)arg1;
- (void)removeRecipient:(id)arg1;
- (void)_updateToField;
- (void)composeRecipientViewReturnPressed:(id)arg1;

@end
