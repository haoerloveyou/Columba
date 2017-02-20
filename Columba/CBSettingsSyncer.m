//
//  CBSettingsSyncer.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-20.
//
//

#import "CBSettingsSyncer.h"

@implementation CBSettingsSyncer

+ (NSDictionary*)defaults
{
	return @{@"enabled": @YES, @"qrEnabled": @YES, @"templates": @[], @"volumeQC": @YES, @"recents": @NO, @"grayscaleOSK": @NO, @"scheduledMessages": @[], @"toolbarItems": @4};
}

+ (id)valueForKey:(NSString*)key
{
	CFPreferencesAppSynchronize(CFSTR("com.mootjeuh.columba"));
	
	return (__bridge id)CFPreferencesCopyAppValue((__bridge CFStringRef)key, CFSTR("com.mootjeuh.columba")) ? : [self defaults][key];
}

+ (void)setValue:(id)value forKey:(NSString*)key
{
	CFPreferencesAppSynchronize(CFSTR("com.mootjeuh.columba"));
	CFPreferencesSetAppValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, CFSTR("com.mootjeuh.columba"));
	CFPreferencesAppSynchronize(CFSTR("com.mootjeuh.columba"));
}

+ (void)resetAllSettings
{
	for(NSString *key in self.defaults) {
		[self setValue:self.defaults[key] forKey:key];
	}
}

@end
