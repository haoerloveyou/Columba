#import "../headers/headers.h"

#import "../Columba/CBButtonsToolbar.h"
#import "../Columba/CBComposeViewController.h"
#import "../Columba/CBMessagingWindowViewController.h"
#import "../Columba/CBReplyWindowViewController.h"
#import "../Columba/CBSocialMediator.h"

%hook SLSheetRootViewController

- (UITableView*)tableView
{
	UITableView *view = %orig;

    if([self.delegate.class isSubclassOfClass:CBMessagingWindowViewController.class]) {
		view.scrollEnabled = NO;

		CGRect frame = view.frame;
		frame.origin.y = self.delegate._intrinsicSheetSize.height-CGRectGetHeight(view.frame)-CGRectGetHeight(self.delegate.navigationController.navigationBar.frame);
		view.frame = frame;
    }

    return view;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = %orig;

    if([self.delegate.class isSubclassOfClass:CBMessagingWindowViewController.class]) {
        cell.textLabel.hidden = YES;
        BOOL shouldContinue = YES;

        for(UIView *subview in cell.subviews) {
            if([subview isKindOfClass:CBButtonsToolbar.class]) {
                shouldContinue = NO;
                break;
            }
        }

        if([cell.textLabel.text isEqualToString:@"toolbar"] && shouldContinue) {
            NSMutableArray *titles = [NSMutableArray arrayWithArray:@[COLUMBA_CALL, COLUMBA_OPEN, COLUMBA_HISTORY, COLUMBA_STRING(@"CB.templates", @"Templates"), COLUMBA_STRING(@"CB.attachments", @"Attachments"), COLUMBA_STRING(@"CB.schedule", @"Schedule")]];

            if([self.delegate isKindOfClass:CBReplyWindowViewController.class]) {
                [titles addObject:COLUMBA_DELETE];
            } else if([self.delegate isKindOfClass:CBComposeViewController.class]) {
				[titles insertObject:COLUMBA_MESSAGES atIndex:3];
			}

            CBButtonsToolbar *toolbar = [[CBButtonsToolbar alloc] initFromSheetViewController:self inCell:cell withTitles:titles];
            toolbar.toolbarDelegate = (id<CBButtonsToolbarDelegate>)self.delegate;
            toolbar.delegate = (id<UIScrollViewDelegate>)self;

			[cell addSubview:toolbar];

            if(!self.CB_pageControl) {
				self.CB_pageControl = [[UIPageControl alloc] init];
            }

            self.CB_pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0 alpha:.5];
            self.CB_pageControl.numberOfPages = toolbar.numberOfPages;
            self.CB_pageControl.pageIndicatorTintColor = tableView.separatorColor;

			if([tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section] == 2) {
				self.CB_pageControl.frame = CGRectMake(0, -11-CGRectGetHeight(cell.frame), CGRectGetWidth(cell.frame), 10);
			} else {
				self.CB_pageControl.frame = CGRectMake(0, -11, CGRectGetWidth(cell.frame), 10);
			}

            [cell addSubview:self.CB_pageControl];
        } else if([cell.textLabel.text isEqualToString:@"ad"] && shouldContinue) {
			self.CB_pageControl.frame = CGRectMake(0, -11-CGRectGetHeight(cell.frame), CGRectGetWidth(cell.frame), 10);

			[CBSocialMediator sharedInstance].view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(cell.frame));

			[cell addSubview:[CBSocialMediator sharedInstance].view];
		}
    }

    return cell;
}

%new
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if([self.delegate.class isSubclassOfClass:CBMessagingWindowViewController.class]) {
        float width = CGRectGetWidth(scrollView.frame);
        float xPos = scrollView.contentOffset.x+10;

        self.CB_pageControl.currentPage = (int)xPos/width;
    }
}

%new
- (UIPageControl*)CB_pageControl
{
	return objc_getAssociatedObject(self, @selector(CB_pageControl));
}

%new
- (void)setCB_pageControl:(UIPageControl*)value
{
	objc_setAssociatedObject(self, @selector(CB_pageControl), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end
