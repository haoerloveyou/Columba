//
//  CBSeparatorLine.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-16.
//
//

#import "CBSeparatorLine.h"

@implementation CBSeparatorLine

+ (BOOL)isWithinViews:(NSArray*)views
{
	BOOL result = NO;
	
	for(id view in views) {
		if([view isKindOfClass:self]) {
			result = YES;
			break;
		}
	}
	
	return result;
}

- (instancetype)initForTableView:(UITableView*)tableView
{
	if((self = [super init])) {
		self.backgroundColor = tableView.separatorColor;
		self.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 1/[UIScreen mainScreen].scale);
	}
	
	return self;
}

@end
