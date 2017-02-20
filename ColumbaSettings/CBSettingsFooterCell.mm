//
//  CBSettingsFooterCell.mm
//  
//
//  Created by Mohamed Marbouh on 2016-09-24.
//
//

#import "CBSettingsFooterCell.h"

@implementation CBSettingsFooterCell

@synthesize label;

- (id)initWithSpecifier:(PSSpecifier*)specifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
	
	if(self) {
		UIView *view = nil;
		
		for(id subview in [[UIApplication sharedApplication].keyWindow allSubviews]) {
			if([NSStringFromClass([subview class]) isEqualToString:@"UIViewControllerWrapperView"]) {
				view = subview;
				break;
			}
		}
		
		if(view) {
			label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(view.frame)+10, CGRectGetWidth(view.frame), 20)];
			label.numberOfLines = 1;
			label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
			label.text = COLUMBA_STRING(@"Prefs.FooterCopyright", @"Columba © 2016 Mohamed Marbouh");
			label.backgroundColor = [UIColor clearColor];
			label.textColor = [UIColor grayColor];
			label.textAlignment = NSTextAlignmentCenter;
			
			[self addSubview:label];
		}
	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
	return 44.f;
}

//E-mail donate link: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TXEFY64LHLWQS

@end
