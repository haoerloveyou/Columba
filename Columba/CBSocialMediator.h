//
//  CBSocialMediator.h
//  
//
//  Created by Mohamed Marbouh on 2016-11-01.
//
//

#import <Foundation/Foundation.h>

@interface CBSocialMediator : NSObject

@property(nonatomic, assign) UIView *view;
@property(nonatomic, assign) UIViewController *viewController;

+ (instancetype)sharedInstance;
- (void)viewDidLoad;

@end
