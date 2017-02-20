//
//  Columba.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-16.
//
//

#import <Foundation/Foundation.h>

@interface Columba : NSObject

+ (BOOL)isActivatorInstalled;
+ (BOOL)isLibStatusBarInstalled;
+ (BOOL)isMessagesCustomizerInstalled;
+ (void)loadActivator;
+ (void)loadLibStatusBar;
+ (float)currentVersion;

@end
