//
//  UIView+Columba.m
//  
//
//  Created by Mohamed Marbouh on 2014-10-26.
//
//

#import "UIView+Columba.h"

@implementation UIView (Columba)

- (NSArray*)allSubviews
{
	NSMutableArray *arr = [NSMutableArray array];
	[arr addObject:self];
	
	for(UIView *subview in self.subviews) {
		[arr addObjectsFromArray:[subview allSubviews]];
	}
	
	return arr;
}

+ (NSArray*)allSubviews
{
	return [[UIApplication sharedApplication].keyWindow allSubviews];
}

@end
