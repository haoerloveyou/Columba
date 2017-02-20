//
//  CBSettingsAboutPrithviHeaderCell.m
//  
//
//  Created by Mohamed Marbouh on 2016-10-28.
//
//

#import "headers/headers.h"

#import "CBSettingsAboutPrithviHeaderCell.h"

@implementation CBSettingsAboutPrithviHeaderCell

- (UIImage*)resizeImage:(UIImage*)source newSize:(CGSize)newSize
{
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
	[source drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *retVal = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return retVal;
}

- (id)initWithSpecifier:(PSSpecifier*)specifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
	
	if(self) {
		UIView *view = nil;
		
		for(id subview in [[UIApplication sharedApplication].keyWindow allSubviews]) {
			if([NSStringFromClass([subview class]) isEqualToString:@"UIViewControllerWrapperView"]) {
				view = subview;
				break;
			}
		}
		
		if(view) {
			UIImage *icon = [UIImage imageNamed:@"Skyfeld-6250x2083.png" inBundle:[NSBundle bundleWithPath:@"/Library/Application Support/Columba/Resources.bundle"] compatibleWithTraitCollection:nil];
			
			CGFloat width = CGRectGetWidth(view.frame);
			CGFloat height = [self preferredHeightForWidth:width];
			
			icon = [self resizeImage:icon newSize:CGSizeMake(width, height)];
			
			_imageView = [[UIImageView alloc] initWithImage:icon];
			
			[self addSubview:_imageView];
		}
	}
	
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
	return 240.f;
}

@end
