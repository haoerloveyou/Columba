//
//  ColumbaUI.h
//  
//
//  Created by Mohamed Marbouh on 2016-11-04.
//
//

#import <UIKit/UIKit.h>

@interface ColumbaUI : NSObject

+ (UIView*)autoLayoutView;
+ (void)makeAutoLayout:(UIView*)view;
+ (void)removeAllConstraints:(UIView*)view;

@end
