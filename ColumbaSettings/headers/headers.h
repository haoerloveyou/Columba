//
//  headers.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-23.
//
//

#ifndef headers_h
#define headers_h

#import <UIKit/UIKit.h>

#import "UIView+Columba.h"

#import "../../Columba/CBLocalizations.h"
#import "../../Columba/CBMessageScheduler.h"
#import "../../Columba/CBSettingsSyncer.h"
#import "../../Columba/Columba.h"

#import "../../headers/libMobileGestalt.h"

#import <substrate.h>

#define UIColorFromRGB(rgbValue) \
			[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
			green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
			blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@protocol PreferencesTableCustomView

- (id)initWithSpecifier:(id)arg1;

@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;

@end

@protocol PSBaseView <NSObject>

- (id)initForContentSize:(CGSize)contentSize;

@end

@interface UITableViewCell ()

- (UITableViewCellStyle)style;

@end

@class PSSpecifier;

@interface PSTableCell : UITableViewCell

@property(nonatomic, retain) PSSpecifier *specifier;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier specifier:(id)specifier;
- (UILabel*)titleLabel;
- (void)setChecked:(BOOL)arg1;

@end

@interface PSTextView : UIView

@property (assign,nonatomic) id delegate;
@property (nonatomic,retain) UIColor * textColor;
@property (nonatomic,copy) NSString * text;

@end

@interface PSTextViewTableCell : PSTableCell

@property (nonatomic,retain) id textView;

@end

@interface PSViewController : UIViewController <PSBaseView>

- (void)pushController:(id)arg1 animate:(BOOL)arg2;
- (void)setParentController:(id)arg1;
- (id)parentController;
- (id)rootController;

@end

@interface PSListController : PSViewController {
	NSArray *_specifiers;
	UITableView* _table;
}

- (void)setTitle:(NSString*)title;
- (id)tableView:(id)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 titleForHeaderInSection:(int)arg2;
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath;
- (id)tableView:(id)arg1 viewForHeaderInSection:(int)arg2;
- (id)tableView:(id)arg1 viewForFooterInSection:(int)arg2;
- (id)table;
- (id)bundle;
- (id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2;
- (NSIndexPath*)indexPathForSpecifier:(PSSpecifier*)specifier;
- (PSSpecifier*)specifierAtIndexPath:(NSIndexPath*)indexPath;
- (PSSpecifier*)specifier;
- (PSSpecifier*)specifierForID:(NSString*)specifier;
- (void)setSpecifier:(PSSpecifier*)specifier;
- (id)controllerForSpecifier:(id)arg1;
- (void)showController:(id)arg1 animate:(BOOL)arg2;
- (void)reload;
- (void)reloadSpecifiers;
- (void)dismissPopoverAnimated:(BOOL)arg1;
- (void)insertSpecifier:(PSSpecifier*)arg1 afterSpecifier:(PSSpecifier*)arg2 animated:(BOOL)arg3;
- (void)removeSpecifier:(PSSpecifier*)specifier animated:(BOOL)animated;
- (void)removeSpecifierID:(NSString*)arg1 animated:(BOOL)arg2;
- (void)reloadSpecifierID:(id)arg1 animated:(BOOL)arg2 ;
- (void)reloadSpecifier:(PSSpecifier*)specifier animated:(BOOL)animated;

@end

typedef enum PSCellType {
	PSGroupCell,
	PSLinkCell,
	PSLinkListCell,
	PSListItemCell,
	PSTitleValueCell,
	PSSliderCell,
	PSSwitchCell,
	PSStaticTextCell,
	PSEditTextCell,
	PSSegmentCell,
	PSGiantIconCell,
	PSGiantCell,
	PSSecureEditTextCell,
	PSButtonCell,
	PSEditTextViewCell,
} PSCellType;

@interface PSSpecifier : NSObject {
	SEL action;
}

@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,retain) NSString *name;
@property (assign,nonatomic) Class detailControllerClass;
@property (nonatomic, retain) NSArray *values;

+ (id)groupSpecifierWithName:(NSString*)name;
+ (id)emptyGroupSpecifier;
+ (id)preferenceSpecifierNamed:(NSString*)arg1 target:(id)arg2 set:(SEL)arg3 get:(SEL)arg4 detail:(Class)arg5 cell:(int)arg6 edit:(Class)arg7;
+ (id)buttonSpecifierWithTitle:(id)arg1 target:(id)arg2 action:(SEL)arg3 confirmationInfo:(id)arg4;
- (void)setProperty:(id)value forKey:(id)key;
- (id)propertyForKey:(id)arg1;
- (void)setProperties:(id)arg1;
- (void)setupIconImageWithPath:(id)arg1;

@end

@interface PSControlTableCell : PSTableCell

@property(nonatomic, retain) UIControl *control;

@end

@interface PSSliderTableCell : PSControlTableCell

- (void)setValue:(id)arg1;

@end

@interface PSUIDateTimePickerCell : PSTableCell {
	UIDatePicker *_datePicker;
}

@end

@interface WallpaperPreviewCell : PSTableCell

@property (setter=_setHomeScreenThumbnailButton:,nonatomic,retain) UIButton * _homeScreenThumbnailButton;              //@synthesize _homeScreenThumbnailButton=__homeScreenThumbnailButton - In the implementation block
@property (setter=_setLockScreenThumbnailButton:,nonatomic,retain) UIButton * _lockScreenThumbnailButton;              //@synthesize _lockScreenThumbnailButton=__lockScreenThumbnailButton - In the implementation block
@property (assign,setter=_setThumbnailSize:,nonatomic) CGSize _thumbnailSize;

@end

void setImage(PSSpecifier *specifier, NSString *imageName);
NSBundle *bundle();

#import "../CBSettingsListController.h"

#ifdef __cplusplus
extern "C" {
#endif
	extern void checkForPayment(void(^completed)(BOOL));
	extern NSString *udid();
	extern BOOL isInternetAvailable();
#ifdef __cplusplus
}
#endif

#endif /* headers_h */
