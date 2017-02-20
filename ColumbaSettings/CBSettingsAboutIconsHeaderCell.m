//
//  CBSettingsAboutIconsHeaderCell.m
//  
//
//  Created by Mohamed Marbouh on 2016-10-28.
//
//

#import "headers/headers.h"

#import "CBSettingsAboutIconsHeaderCell.h"

@implementation CBSettingsAboutIconsHeaderCell

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
			self.backgroundColor = UIColorFromRGB(0x3BC053);
			
			UIImage *icon = [UIImage imageNamed:@"Icons8-1400x1400.png" inBundle:[NSBundle bundleWithPath:@"/Library/Application Support/Columba/Resources.bundle"] compatibleWithTraitCollection:nil];
			icon = [self resizeImage:icon newSize:CGSizeMake(200, 200)];
			
			_imageView = [[UIImageView alloc] initWithImage:icon];
			
			CGRect frame = _imageView.frame;
			frame.origin.x = (CGRectGetWidth(view.frame)-CGRectGetWidth(frame))/2;
			frame.origin.y = ([self preferredHeightForWidth:CGRectGetWidth(view.frame)]-CGRectGetHeight(frame))/2;
			_imageView.frame = frame;
			
			_imageView.layer.cornerRadius = 5;
			_imageView.layer.masksToBounds = YES;
			
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
