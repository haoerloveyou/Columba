//
//  Columba.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-16.
//
//

#import "Columba.h"

#include <dlfcn.h>
#include <objc/runtime.h>

@implementation Columba

+ (BOOL)isActivatorInstalled
{
	return [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libactivator.dylib"];
}

+ (BOOL)isLibStatusBarInstalled
{
	return [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib"];
}

+ (BOOL)isMessagesCustomizerInstalled
{
	return [[objc_getClass("CHQuickSwitcher") alloc] init] != nil;
}

+ (void)loadActivator
{
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
}

+ (void)loadLibStatusBar
{
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
}

+ (float)currentVersion
{
	return .5;
}

@end
