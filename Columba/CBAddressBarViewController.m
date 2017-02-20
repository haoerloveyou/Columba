//
//  CBAddressBarViewController.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-18.
//
//

#import "CBAddressBarViewController.h"

@interface CKIMComposeRecipient : NSObject

@property (nonatomic,retain) NSString * displayString;

@end

@interface UIView ()

-(void)_replaceLayer:(id)arg1;

@end

@interface CBAddressBarViewController ()

@property BOOL addedPlaceholderRecipient;

@end

@implementation CBAddressBarViewController

- (instancetype)init
{
	if((self = [super init])) {
		self.addedPlaceholderRecipient = NO;
		self.backdropView = nil;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	for(UIView *view in self.toFieldContainerView.subviews) {
		if([view isKindOfClass:objc_getClass("_UIBackdropView")]) {
			self.backdropView = view;
			break;
		}
	}
	
	if(self.backdropView) {
		for(UIView *view in self.backdropView.subviews) {
			if([view isKindOfClass:objc_getClass("_UIBackdropEffectView")]) {
				id msgCustomizerObject = [[objc_getClass("CHQuickSwitcher") alloc] init];
				
				if(!msgCustomizerObject) {
					[view _replaceLayer:nil];
				}
				
				break;
			}
		}
		
		self.backdropView.hidden = YES;
	}
}

- (void)composeRecipientViewReturnPressed:(id)arg1
{
	[super composeRecipientViewReturnPressed:arg1];
	
	if(self.searchListController.enteredRecipients > 0) {
		if([self.delegate respondsToSelector:@selector(acceptTextInput)]) {
			[(NSObject*)self.delegate performSelector:@selector(acceptTextInput) withObject:nil afterDelay:0];
		}
	}
}

- (void)recipientViewDidBecomeFirstResponder:(UIView*)view
{
	[super recipientViewDidBecomeFirstResponder:view];
	
	if(!self.addedPlaceholderRecipient) {
		self.addedPlaceholderRecipient = YES;
		[self composeRecipientView:view didFinishEnteringAddress:@"columba"];
	}
	
	self.backdropView.hidden = NO;
}

- (void)recipientViewDidResignFirstResponder:(id)arg1
{
	[super recipientViewDidResignFirstResponder:arg1];
	
	self.backdropView.hidden = YES;
}

- (void)notifyDelegateOfChangedRecipientsIfPossible
{
	if([self.delegate respondsToSelector:@selector(recipientsChanged)]) {
		[(NSObject*)self.delegate performSelector:@selector(recipientsChanged) withObject:nil afterDelay:0];
	}
}

- (void)addRecipient:(CKIMComposeRecipient*)arg1
{
	[super addRecipient:arg1];
	
	if([arg1.displayString isEqualToString:@"columba"]) {
		[self removeRecipient:arg1];
	} else {
		[self notifyDelegateOfChangedRecipientsIfPossible];
	}
}

- (void)removeRecipient:(CKIMComposeRecipient*)recipient
{
	[super removeRecipient:recipient];
	[self notifyDelegateOfChangedRecipientsIfPossible];
}

@end
