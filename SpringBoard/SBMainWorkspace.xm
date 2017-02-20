#import "../headers/headers.h"

#import "../Columba/CBCommunicationsHandler.h"
#import "../Columba/CBMessageScheduler.h"

%hook SBMainWorkspace

+ (void)start
{
    %orig;

	if([[CBSettingsSyncer valueForKey:@"enabled"] boolValue]) {
	    NSDate *now = [NSDate date];

	    for(NSDictionary *entry in [CBMessageScheduler registeredMessages]) {
	        if([[NSCalendar currentCalendar] compareDate:now toDate:entry[@"date"] toUnitGranularity:NSCalendarUnitMinute] == NSOrderedAscending) {
	            [CBMessageScheduler scheduleMessage:entry];
	        }
	    }
	}

    [CBCommunicationsHandler setupServer];

	dispatch_async(dispatch_get_main_queue(), ^{
        if ([Columba isActivatorInstalled]) {
            [Columba loadActivator];
            [[%c(LAActivator) sharedInstance] registerListener:[CBActivatorListener sharedInstance]
                                                       forName:@"Columba Compose"];
        }
    });
}

%end
