//
//  CBButtonsToolbar.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-18.
//
//

#import <UIKit/UIKit.h>
#import "../headers/headers.h"

@protocol CBButtonsToolbarDelegate <NSObject>

@required
- (void)buttonTapped:(id)sender;

@end

@interface CBButtonsToolbar : UIScrollView

@property NSInteger numberOfPages;
@property(nonatomic) id<CBButtonsToolbarDelegate> toolbarDelegate;

- (instancetype)initFromSheetViewController:(SLSheetRootViewController*)viewController inCell:(UITableViewCell*)cell withTitles:(NSArray*)titles;
- (UIButton*)buttonWithTitle:(NSString*)title;

@end
