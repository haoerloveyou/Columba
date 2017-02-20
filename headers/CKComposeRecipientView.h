@interface CKComposeRecipientView : UIView {
	NSMutableArray *_atomViews;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, readonly) UITextView *textView;

- (void)_setAddButtonVisible:(BOOL)visible animated:(BOOL)animated;

@end
