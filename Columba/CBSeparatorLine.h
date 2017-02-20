//
//  CBSeparatorLine.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-16.
//
//

#import <UIKit/UIKit.h>

@interface CBSeparatorLine : UIView

+ (BOOL)isWithinViews:(NSArray*)subviews;
- (instancetype)initForTableView:(UITableView*)tableView;

@end
