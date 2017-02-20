//
//  CBLocalizations.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-18.
//
//

#import "CBLocalizations.h"
#import "Columba.h"

@interface CBLocalizations ()

@property(nonatomic) NSBundle *bundle;
@property(nonatomic) NSMutableDictionary *strings;

@end

@implementation CBLocalizations

+ (instancetype)sharedInstance
{
	static CBLocalizations *sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSString *path;
		
		sharedInstance = [[self alloc] init];
		sharedInstance.bundle = [NSBundle bundleWithPath:@"/Library/Application Support/Columba/Strings.bundle"];
		sharedInstance.strings = [NSMutableDictionary dictionary];
		
		if([objc_getClass("Columba") isActivatorInstalled]) {
			[sharedInstance.strings addEntriesFromDictionary:[self loadSystemAppStrings:@"Activator" file:nil]];
		}
		
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemAppStrings:@"MobilePhone" file:@"General"]];
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemAppStrings:@"MobileSMS" file:nil]];
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemFrameworkStrings:@"ChatKit" file:@"ChatKit"]];
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemFrameworkStrings:@"PreferencesUI" file:@"Display"]];
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemFrameworkStrings:@"PreferencesUI" file:@"General~iphone"]];
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemFrameworkStrings:@"PreferencesUI" file:@"Network~iphone"]];
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemFrameworkStrings:@"PreferencesUI" file:@"Reset~iphone"]];
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemFrameworkStrings:@"PreferencesUI" file:@"Settings~iphone"]];
		[sharedInstance.strings addEntriesFromDictionary:[self loadSystemFrameworkStrings:@"PreferencesUI" file:@"Sounds~iphone"]];
		
		path = [self getCorrectPath:@"/System/Library/PreferenceBundles/KeyboardSettings.bundle" file:@"KeyboardTitles"];
		[sharedInstance.strings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
		
		path = [self getCorrectPath:@"/System/Library/PreferenceBundles/AccessibilitySettings.bundle" file:@"Accessibility"];
		[sharedInstance.strings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
		
		path = [self getCorrectPath:@"/System/Library/CoreServices/SpringBoard.app" file:@"SpringBoard"];
		[sharedInstance.strings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
		
		path = [self getCorrectPath:@"/System/Library/CoreServices/SpringBoard.app" file:@"BulletinBoard"];
		[sharedInstance.strings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
		
		path = [self getCorrectPath:@"/System/Library/BulletinBoardPlugins/SMSBBPlugin.bundle" file:@"SMSBBPlugin"];
		[sharedInstance.strings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	});
	
	return sharedInstance;
}

- (NSString*)localizedString:(NSString*)key backup:(NSString*)failsafe
{
	NSString *bundleString = [self.bundle localizedStringForKey:key value:failsafe table:nil];
	return self.strings[key] ? : bundleString;
}

+ (NSDictionary*)loadSystemAppStrings:(NSString*)app file:(NSString*)stringsFile
{	
	NSString *stringsPath = [self getCorrectPath:[NSString stringWithFormat:@"/Applications/%@.app", app] file:stringsFile];
	return [NSDictionary dictionaryWithContentsOfFile:stringsPath];
}

+ (NSDictionary*)loadSystemFrameworkStrings:(NSString*)framework file:(NSString*)stringsFile
{
	NSString *stringsPath = [self getCorrectPath:[NSString stringWithFormat:@"/System/Library/PrivateFrameworks/%@.framework", framework] file:stringsFile];
	return [NSDictionary dictionaryWithContentsOfFile:stringsPath];
}

+ (NSString*)getCorrectPath:(NSString*)path file:(NSString*)stringsFile
{
	NSString *file = stringsFile ? : @"Localizable";
	NSString *result = [NSString stringWithFormat:@"%@/%@.lproj/%@.strings", path, [[NSLocale preferredLanguages] firstObject], file];
	unsigned char try = 0;
	
	while(![[NSFileManager defaultManager] fileExistsAtPath:result]) {
		if(try == 0) {
			result = [NSString stringWithFormat:@"%@/%@.lproj/%@.strings", path, [[[NSBundle mainBundle] preferredLocalizations] firstObject], file];
			try++;
		} else if(try == 1) {
			NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
			NSMutableString *variable = [NSMutableString stringWithString:[locale displayNameForKey:NSLocaleIdentifier value:[[NSLocale currentLocale] localeIdentifier]]];
			NSRange start = [variable rangeOfString:@"("];
			NSRange end = [variable rangeOfString:@")"];
			
			@try {
				[variable deleteCharactersInRange:(NSRange){start.location, end.location - start.location + 1}];
				[variable replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, variable.length)];
			} @catch (NSException *exception) {
				if(exception.name == NSRangeException) {
					NSLog(@"[Columba Localization] Caught NSRange exception: %@", exception);
					NSLog(@"[Columba Localization] Range start,end | Variable: %@,%@ | %@", NSStringFromRange(start), NSStringFromRange(end), variable);
				}
			}
			
			result = [NSString stringWithFormat:@"%@/%@.lproj/%@.strings", path, variable, file];
			try++;
		} else {
			break;
		}
	}
	
	return result;
}

@end
