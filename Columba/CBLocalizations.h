//
//  CBLocalizations.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-18.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface CBLocalizations : NSObject

+ (instancetype)sharedInstance;
- (NSString*)localizedString:(NSString*)key backup:(NSString*)failsafe;

@end

static inline NSString *COLUMBA_STRING(NSString *key, NSString *backup)
{
	return [[objc_getClass("CBLocalizations") sharedInstance] localizedString:key  backup:backup];
}

#define COLUMBA_CANCEL		COLUMBA_STRING(@"CANCEL", @"Cancel")
#define COLUMBA_OK 			COLUMBA_STRING(@"OK", @"OK")
#define COLUMBA_SAVE		COLUMBA_STRING(@"BALLOON_EXPORT_CALLOUT", @"Save")
#define COLUMBA_DISMISS		COLUMBA_STRING(@"DISMISS", @"Dismiss")
#define COLUMBA_DELETE		COLUMBA_STRING(@"DELETE", @"Delete")
#define COLUMBA_REPLY		COLUMBA_STRING(@"REPLY", @"Reply")
#define COLUMBA_SEND		COLUMBA_STRING(@"SEND", @"Send")
#define COLUMBA_CALL		COLUMBA_STRING(@"CALL", @"Call")
#define COLUMBA_OPEN		COLUMBA_STRING(@"OPEN", @"Open")
#define COLUMBA_EMOJI		COLUMBA_STRING(@"emoji", @"Emoji")
#define COLUMBA_FORWARD		COLUMBA_STRING(@"Button.Forward", @"Forward")
#define COLUMBA_HISTORY		COLUMBA_STRING(@"Button.History", @"History")
#define COLUMBA_DATE		COLUMBA_STRING(@"Prefs.ScheduledMsgs.Date", @"Date")
#define COLUMBA_TEXT		COLUMBA_STRING(@"Prefs.ScheduledMsgs.Text", @"Text")
#define COLUMBA_CLEAR		COLUMBA_STRING(@"BULLETIN_LIST_CLEAR", @"Clear")
#define COLUMBA_RECIPIENT	COLUMBA_STRING(@"Prefs.ScheduledMsgs.Recipient", @"Recipient")
#define COLUMBA_DONE		COLUMBA_STRING(@"DONE", @"Done")
#define COLUMBA_RESET		COLUMBA_STRING(@"RESET", @"Reset")
#define COLUMBA_TEMPLATES	COLUMBA_STRING(@"TEMPLATES", @"Templates")
#define COLUMBA_MESSAGES	COLUMBA_STRING(@"APP_TITLE", @"Conversations")
