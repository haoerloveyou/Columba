//
//  CBSettingsHeaderLogoCell.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-24.
//
//

#import <UIKit/UIKit.h>
#import "headers/headers.h"

@interface CBSettingsHeaderLogoCell : PSTableCell <PreferencesTableCustomView> {
	UILabel *_label;
	UIImageView *_imageView;
}

- (UIImage*)resizeImage:(UIImage*)source newSize:(CGSize)newSize;

@end
