@interface SLSheetTextComposeView : UIView

@property (nonatomic,retain) UITextView * textView;

@end

@interface SLSheetContentView : UIView {
	SLSheetTextComposeView* _textComposeView;
}

@property (nonatomic,readonly) UITextView * textView;

@end