//
//  ColumbaUI.m
//  
//
//  Created by Mohamed Marbouh on 2016-11-04.
//
//

#import "ColumbaUI.h"

@implementation ColumbaUI

+ (UIView*)autoLayoutView
{
	UIView *view = [[UIView alloc] init];
	
	[self makeAutoLayout:view];
	
	return view;
}

+ (void)makeAutoLayout:(UIView*)view
{
	view.translatesAutoresizingMaskIntoConstraints = NO;
}

+ (void)removeAllConstraints:(UIView*)view
{
	UIView *superview = view.superview;
	
	while(superview != nil) {
		for(NSLayoutConstraint *c in superview.constraints) {
			if(c.firstItem == self || c.secondItem == view) {
				[superview removeConstraint:c];
			}
		}
		
		superview = superview.superview;
	}
	
	[view removeConstraints:view.constraints];
}

@end
