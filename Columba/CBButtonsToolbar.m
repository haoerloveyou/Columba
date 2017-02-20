//
//  CBButtonsToolbar.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-18.
//
//

#import "CBButtonsToolbar.h"
#import "CBButtonsToolbarButton.h"
#import "CBComposeViewController.h"

@interface CBButtonsToolbar ()

@property(nonatomic, retain) NSMutableArray *pages;

@end

@implementation CBButtonsToolbar

- (instancetype)initFromSheetViewController:(SLSheetRootViewController*)viewController inCell:(UITableViewCell*)cell withTitles:(NSArray*)titles
{
	float height = CGRectGetHeight(cell.frame);
	
	if((self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewController.view.frame), height)])) {
		self.pages = [NSMutableArray array];
		NSArray *titlesPerPage = [self sortTitles:titles];
		
		self.showsHorizontalScrollIndicator = NO;
		self.pagingEnabled = YES;
		self.contentSize = CGSizeMake(self.frame.size.width*titlesPerPage.count, height);
		
		for(int i = 0; i < titlesPerPage.count; i++) {
			[self.pages addObject:[NSMutableArray array]];
			
			for(int j = 0; j < [titlesPerPage[i] count]; j++) {
				CBButtonsToolbarButton *button = [[CBButtonsToolbarButton alloc] initWithTitle:titlesPerPage[i][j]];
				
				[button addTarget:self.toolbarDelegate action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
				[button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
				
				float x = i == 0 ? i : self.frame.size.width*i;
				button.frame = CGRectMake(x, 0, self.frame.size.width/4, height);
				
				if(j > 0) {
					CGRect frame = [self.pages[i][j-1] frame];
					float extra = frame.origin.x+frame.size.width;
					frame = button.frame;
					if(i == 0) {
						frame.origin.x += extra;
					} else {
						frame.origin.x = extra;
					}
					button.frame = frame;
				}
				
				if(!(i == 0 && j == 0)) {
					[button configureWithColour:viewController.tableView.separatorColor];
				}
				
				[self.pages[i] addObject:button];
			}
		}
		
		for(int i = 0; i < self.pages.count; i++) {
			for(CBButtonsToolbarButton *button in self.pages[i]) {
				[self addSubview:button];
			}
		}
		
		self.numberOfPages = self.pages.count;
	}
	
	return self;
}

- (CBButtonsToolbarButton*)buttonWithTitle:(NSString*)title
{
	CBButtonsToolbarButton *result = nil;
	
	for(NSArray *page in self.pages) {
		for(CBButtonsToolbarButton *button in page) {
			if([button.titleLabel.text isEqualToString:title]) {
				result = button;
				break;
			}
		}
	}
	
	return result;
}

- (NSArray*)sortTitles:(NSArray*)titles
{
	NSMutableArray *arrayOfArrays = [NSMutableArray array];
	
	int i = 0, itemsRemaining = titles.count;
	
	while(i < titles.count) {
		NSRange range = NSMakeRange(i, MIN([[CBSettingsSyncer valueForKey:@"toolbarItems"] intValue], itemsRemaining));
		NSArray *subarray = [titles subarrayWithRange:range];
		
		[arrayOfArrays addObject:subarray];
		
		itemsRemaining -= range.length;
		i += range.length;
	}
	
	return arrayOfArrays;
}

- (void)setToolbarDelegate:(id<CBButtonsToolbarDelegate>)delegate
{
	_toolbarDelegate = delegate;
	
	for(int i = 0; i < self.pages.count; i++) {
		for(CBButtonsToolbarButton *button in self.pages[i]) {
			[button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
			[button addTarget:delegate action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
		}
	}
}

@end
