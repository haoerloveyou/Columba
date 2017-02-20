//
//  CBSettingsHeaderLogoCell.mm
//  
//
//  Created by Mohamed Marbouh on 2016-09-24.
//
//

#import "CBSettingsHeaderLogoCell.h"

@implementation CBSettingsHeaderLogoCell

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
			UIImage *image = [UIImage imageNamed:@"SettingsIcon" inBundle:bundle() compatibleWithTraitCollection:nil];
			UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTapped:)];
			
			image = [self resizeImage:image newSize:CGSizeMake(200, 200)];
			_imageView = [[UIImageView alloc] initWithImage:image];
			CGRect temp = _imageView.frame;
			temp.origin.y = 5;
			temp.origin.x = (CGRectGetWidth(view.frame)-CGRectGetWidth(temp))/2;
			_imageView.frame = temp;
			
			_label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_imageView.frame)+5, CGRectGetWidth(view.frame), 20)];
			[_label setNumberOfLines:1];
			_label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
			[_label setText:COLUMBA_STRING(@"Prefs.Credits", @"Developed by Mohamed Marbouh")];
			[_label setBackgroundColor:[UIColor clearColor]];
			_label.textColor = [UIColor grayColor];
			_label.textAlignment = NSTextAlignmentCenter;
			
			[self addGestureRecognizer:tap];
			[self addSubview:_imageView];
			[self addSubview:_label];
		}
	}
	
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
	return 240.f;
}

- (void)spinView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
	CABasicAnimation* rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * rotations * duration ];
	rotationAnimation.duration = duration;
	rotationAnimation.cumulative = YES;
	rotationAnimation.repeatCount = repeat;
	
	[view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)iconTapped:(id)sender
{
	[self spinView:_imageView duration:1 rotations:1 repeat:0];
}

@end
