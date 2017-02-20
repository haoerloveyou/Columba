@interface CKRecipientSearchListController : UITableViewController

@property(assign, nonatomic) id delegate;
@property(nonatomic, retain) NSArray *enteredRecipients;

@end