#import "../headers/headers.h"

@interface CKTextBalloonView : UIView

@property(nonatomic, copy) NSAttributedString *attributedText;

@end

static NSString *latestText = nil;

%hook CKTranscriptCollectionViewController

- (NSArray*)menuItemsForBalloonView:(CKTextBalloonView*)balloonView
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:%orig];

    if([balloonView respondsToSelector:@selector(attributedText)]) {
		latestText = balloonView.attributedText.string;
		NSString *title = [NSString stringWithFormat:@"+ %@", COLUMBA_STRING(@"CK.template", @"Template")];
		UIMenuItem *templateItem = [[%c(UIMenuItem) alloc] initWithTitle:title action:@selector(CB_addTemplate)];
		[result insertObject:templateItem atIndex:0];
    }

	return result;
}

%new
- (void)CB_addTemplate
{
	NSMutableArray *templates = [NSMutableArray arrayWithArray:[%c(CBSettingsSyncer) valueForKey:@"templates"]];

    [templates insertObject:latestText atIndex:0];

	[%c(CBSettingsSyncer) setValue:templates forKey:@"templates"];
}

%end
