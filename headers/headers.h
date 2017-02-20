//
//  headers.h
//  sharetest
//
//  Created by Mohamed Marbouh on 2016-09-16.
//  Copyright © 2016 Mohamed Marbouh. All rights reserved.
//

#ifndef headers_h
#define headers_h

#import <objc/runtime.h>

#import <substrate.h>

#import <libactivator/libactivator.h>

#import <Contacts/Contacts.h>
#import <Social/Social.h>

#import "CKRecipientSearchListController.h"
#import "CKRecipientSelectionController.h"
#import "CKComposeRecipientSelectionController.h"
#import "CKComposeRecipientView.h"
#import "CKComposition.h"
#import "CKConversation.h"
#import "CKConversationList.h"
#import "CKEntity.h"
#import "CKTranscriptCollectionViewController.h"

#import "CNContactStoreDataSource.h"
#import "CNiOSAddressBook.h"

#import "IMChat.h"
#import "IMHandle.h"
#import "IMMessage.h"
#import "IMMessagePartChatItem.h"
#import "IMPerson.h"
#import "IMService.h"

#import "MFComposeRecipient.h"
#import "MFModernComposeRecipientAtom.h"

#import "SBLockScreenManager.h"

#import "SpringBoard.h"

#import "SLSheetContentView.h"
#import "SLSheetRootViewController.h"

@interface SLComposeServiceViewController (Columba)

@property(nonatomic, retain) SLSheetRootViewController *sheetRootViewController;
@property (readonly) BOOL wasPresented;

- (CGSize)_intrinsicSheetSize;
- (void)_presentSheet;
- (CGRect)sheetFrameForViewController:(id)arg1;
- (void)hideKeyboardAnimated:(BOOL)animated;
- (void)showKeyboardAnimated:(BOOL)animated;
- (void)cancelButtonTapped:(id)arg1;
- (void)postButtonTapped:(id)arg1;
- (void)reloadConfigurationItems;
- (void)animateSheetPresentationWithDuration:(double)arg1;
- (void)animateSheetCancelWithDuration:(double)arg1;

@end

@interface CNContact () {
	int _iOSLegacyIdentifier;
}

@property(nonatomic, readonly) int iOSLegacyIdentifier;

+ (instancetype)contactWithIdentifier:(NSString*)identifier;

@end

@interface CNContactStore ()

- (instancetype)initWithAddressBook:(void*)addressBook;

@end

@interface UIViewController ()

@property(nonatomic, retain) UIViewController *childModalViewController;

@end

@interface BBAttachments : NSObject

-(NSUInteger)numberOfAdditionalAttachments;

@end

@interface BBContent : NSObject

@property (nonatomic,copy) NSString * message;
@property (nonatomic,copy) NSString * title;

@end

@interface BBBulletin : NSObject

@property (nonatomic,retain) BBAttachments *attachments;
@property (nonatomic,retain) BBContent * content;
@property(nonatomic, retain) NSDictionary *context;
@property(nonatomic, copy) NSString *sectionID;
@property (nonatomic,retain) NSDate * date;

@end

@interface SBBulletinBannerItem : NSObject

- (BBBulletin*)seedBulletin;

@end

@interface SBLockScreenNotificationBulletinBannerItem : NSObject

- (BBBulletin*)_bulletinListItem;

@end

@interface SBAwayBulletinListItem : NSObject

@property(retain) BBBulletin *activeBulletin;

@end

@interface SBUIBannerContext : NSObject

@property(readonly, assign, nonatomic) SBBulletinBannerItem *item;

@end

@interface SBBannerContextView : UIView

- (SBUIBannerContext*)bannerContext;

@end

@interface PCPersistentTimer : NSObject {
	id _userInfo;
}

+ (id)_backgroundUpdateQueue;
- (instancetype)initWithFireDate:(NSDate*)date serviceIdentifier:(NSString*)identifier target:(id)target selector:(SEL)action userInfo:(NSDictionary*)userInfo;
- (void)scheduleInQueue:(id)arg1;
- (void)scheduleInRunLoop:(id)arg1;
- (void)invalidate;
- (BOOL)isValid;

@end

@interface SLSheetNavigationController : UINavigationController

@end

@interface UIDateLabel : UILabel

@property(nonatomic, retain) NSDate *date;

@end

@interface CKAttachmentView : UIView

@property (nonatomic,retain) UILabel * titleLabel;

@end

@interface CKAvatarView : UIControl

@property (nonatomic,retain) CNContact * contact;
@property(nonatomic, retain) NSArray *contacts;
@property (nonatomic,readonly) UIImage * contentImage; 
@property (nonatomic,retain) UIButton * imageButton;
@property (assign,nonatomic) UIViewController * presentingViewController;
@property (assign,nonatomic) BOOL needsUpdate;

- (instancetype)initWithContact:(CNContact*)contact;
- (void)_updateAvatarView;
- (void)contactDidChange;

@end

@interface CKConversationListCell : UITableViewCell {
	UIDateLabel *_dateLabel;
	UILabel *_summaryLabel;
	UIImageView *_unreadIndicatorImageView;
	UIImageView *_chevronImageView;
	UILabel *_fromLabel;
}

@property(nonatomic, retain) CKAvatarView *avatarView;
@property(nonatomic, retain) CKConversation *conversation;

+ (NSString*)identifierForConversation:(CKConversation*)conversation;
- (void)updateContentsForConversation:(CKConversation*)conversation;

@end

@interface CKConversationListController : UITableViewController

@property(assign, nonatomic) double conversationCellHeight;
@property(assign, nonatomic) CKConversationList *conversationList;

-(BOOL)searchBarShouldBeginEditing:(id)arg1 ;
-(void)searchBarTextDidEndEditing:(id)arg1 ;

@end

@interface CKPhotoPickerController : UIAlertController

@property(nonatomic, assign) SLComposeServiceViewController *delegate;
@property (nonatomic,retain) UIAlertAction * topAlertAction;
@property (nonatomic,retain) UIAlertAction * bottomAlertAction;

@end

@interface CKPhotoPickerItemForSending : NSObject

@property(nonatomic, retain, readonly) NSURL *assetURL;
@property(nonatomic, retain, readonly) NSURL *localURL;
@property(nonatomic, readonly) BOOL isVideo;
@property(retain) UIImage *thumbnail;

@end

@interface CKIMFileTransfer : NSObject

- (instancetype)initWithFileURL:(NSURL*)url transcoderUserInfo:(NSDictionary*)userInfo;

@end

@interface CKMediaObject : NSObject

@property(nonatomic,copy,readonly) NSData *data;
@property (nonatomic,copy,readonly) NSDictionary * transcoderUserInfo;
@property (nonatomic,copy,readonly) NSString * UTIType;

- (instancetype)initWithTransfer:(CKIMFileTransfer*)transfer;
- (id)generateThumbnailForWidth:(double)arg1 orientation:(char)arg2 ;

@end

@interface _CKPhotoPickerComposition : CKComposition

+ (instancetype)compositionWithMediaObject:(CKMediaObject*)object subject:(NSString*)subject;
+ (instancetype)compositionWithMediaObjects:(NSArray<CKMediaObject*>*)objects subject:(NSString*)subject;

@end

@interface CKMediaObjectManager : NSObject

+ (instancetype)sharedInstance;
- (CKMediaObject*)mediaObjectWithFileURL:(NSURL*)arg1 filename:(NSString*)arg2 transcoderUserInfo:(NSDictionary*)arg3;
- (CKMediaObject*)mediaObjectWithData:(NSData*)arg1 UTIType:(NSString*)arg2 filename:(NSString*)arg3 transcoderUserInfo:(NSDictionary*)arg4;

@end

@interface CKImagePickerController : UIImagePickerController

@end

@interface CKChatItem : NSObject

@property (nonatomic,copy) NSAttributedString * transcriptText;
@property (nonatomic,copy) NSAttributedString * transcriptDrawerText;

- (instancetype)initWithIMChatItem:(id)chatItem maxWidth:(CGFloat)width;

@end

@interface CKTextMessagePartChatItem : CKChatItem

@property (nonatomic,copy,readonly) NSAttributedString * text;
@property (nonatomic,readonly) BOOL containsHyperlink;

- (NSAttributedString*)loadTranscriptText;

@end

@interface IMChatRegistry : NSObject

@property(nonatomic, readonly) NSArray *allExistingChats;

+ (instancetype)sharedInstance;

@end

#ifdef __cplusplus
extern "C" {
#endif
	extern void checkForPayment(void(^completed)(BOOL));
	extern NSString *udid();
	extern BOOL isInternetAvailable();
#ifdef __cplusplus
}
#endif

#import "../Columba/Columba.h"
#import "../Columba/ColumbaUI.h"
#import "../Columba/CBActivatorListener.h"
#import "../Columba/CBLocalizations.h"
#import "../Columba/CBSettingsSyncer.h"

#endif /* headers_h */
