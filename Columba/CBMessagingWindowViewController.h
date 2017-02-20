//
//  CBMessagingWindowViewController.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-23.
//
//

#import <UIKit/UIKit.h>
#import "CBButtonsToolbar.h"
#import "CBMessagingWindowPreviewsView.h"

@interface CBMessagingWindowViewController : SLComposeServiceViewController <CBButtonsToolbarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(weak) CBButtonsToolbar *buttonsToolbar;
@property(weak) UIButton *attachmentsButton;
@property(weak) UIButton *templatesButton;
@property(weak) UIButton *scheduleButton;

@property(nonatomic) CKConversation *conversation;
@property(nonatomic) NSMutableArray *pickedAttachments;
@property(nonatomic, retain) CBMessagingWindowPreviewsView *previewsView;
@property(weak) NSArray *recipients;
@property BOOL shouldShowOSK;

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

- (void)changeActionButtonColour:(UIColor*)colour;

- (void)switchToDatePicker;

- (void)recipientsChanged;
- (void)completeDismissal;
- (void)makeToolbarButtonsChecks;
- (void)simulateSendAction;

@end
