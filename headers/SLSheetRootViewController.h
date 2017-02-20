@interface SLSheetRootViewController : UIViewController

@property(nonatomic, retain) SLSheetContentView *contentView;
@property(assign, nonatomic) SLComposeServiceViewController *delegate;
@property(nonatomic, readonly) UITableView *tableView;

@property(nonatomic, retain) UIPageControl *CB_pageControl;

- (void)updateContentViewSize:(CGSize)arg1;

@end
