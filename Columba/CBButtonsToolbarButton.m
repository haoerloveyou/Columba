//
//  CBButtonsToolbarButton.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-18.
//
//

#import "CBButtonsToolbarButton.h"

@implementation CBButtonsToolbarButton

- (instancetype)initWithTitle:(NSString*)title
{
	self = [super init];
	
	if(self) {
		[self setTitle:title forState:UIControlStateNormal];
		[self setTitleColor:[UIColor colorWithRed:0 green:.478431 blue:1 alpha:1] forState:UIControlStateNormal];
		[self.titleLabel setAdjustsFontSizeToFitWidth:YES];
	}
	
	return self;
}

- (void)configureWithColour:(UIColor*)colour
{
	UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(self.frame))];
	separatorLine.backgroundColor = colour;
	separatorLine.alpha = .6;
	
	[self addSubview:separatorLine];
}

@end
