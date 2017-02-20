//
//  CBMessagingWindowPreviewsView.m
//  
//
//  Created by Mohamed Marbouh on 2016-10-12.
//
//

#import "../headers/headers.h"

#import "CBMessagingWindowViewController.h"
#import "CBMessagingWindowPreviewsView.h"

@interface CBMessagingWindowPreviewsView ()

@property CGFloat defaultWidth;
@property CGFloat defaultHeight;
@property NSInteger items;

@property(nonatomic) CKAttachmentView *attachmentView;

@end

@implementation CBMessagingWindowPreviewsView

- (instancetype)init
{
	if((self = [super init])) {
		self.defaultHeight = 64.f;
		self.defaultWidth = 64.f;
		self.items = 0;
		
		self.attachmentView = [[CKAttachmentView alloc] initWithFrame:CGRectMake(0, 0, self.defaultWidth, self.defaultHeight)];
		self.attachmentView.backgroundColor = UIColor.whiteColor;
		self.attachmentView.layer.borderColor = UIColor.lightGrayColor.CGColor;
		self.attachmentView.layer.borderWidth = .7f;
		self.attachmentView.layer.cornerRadius = 5;
		self.attachmentView.titleLabel.text = @"?";
	}
	
	return self;
}

- (UIImage *) imageWithView:(UIView *)view
{
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return img;
}

- (void)messagingViewController:(CBMessagingWindowViewController*)viewController processItems:(NSArray*)items completion:(void (^)())block
{
	void (^animate)(UIImageView*, CGPoint, BOOL) = ^(UIImageView *imageView, CGPoint destination, BOOL isFinal) {		
		CGRect frame;
		frame.origin = CGPointMake(CGRectGetWidth(self.window.frame)/3, CGRectGetHeight(self.window.frame)-self.defaultHeight-5);
		frame.size = CGSizeMake(self.defaultWidth, self.defaultHeight);
		imageView.frame = frame;
		
		CGRect destinationRect = CGRectMake(destination.x, destination.y, self.defaultWidth, self.defaultHeight);
		
		[UIView animateWithDuration:.7f delay:.17f options:UIViewAnimationOptionTransitionCurlUp animations:^{
			[self.window addSubview:imageView];
			
			imageView.frame = [self convertRect:destinationRect toView:self.window];
		} completion:^(BOOL finished) {
			[imageView removeFromSuperview];
			
			imageView.frame = destinationRect;
			
			[self addSubview:imageView];
			
			if(isFinal && block) {
				block();
			}
		}];
	};

	if(self.items == 0) {
		self.translatesAutoresizingMaskIntoConstraints = YES;
		
		CGRect frame = self.frame;
		frame.origin.x = CGRectGetWidth(self.superview.frame)-self.defaultWidth-5;
		frame.origin.y = (CGRectGetHeight(self.superview.frame)-self.defaultHeight)/2;
		self.frame = frame;
	}
	
	if(items.count > 1) {
		NSUInteger total = items.count > 3 ? 3 : items.count;
		
		for(int i = 0; i < total; i++) {
			UIImage *image = nil;
			
			if([items[0] respondsToSelector:@selector(thumbnail)]) {
				image = [items[0] thumbnail];
			} else if([items[0] respondsToSelector:@selector(generateThumbnailForWidth:orientation:)]) {
				image = [items[0] generateThumbnailForWidth:self.defaultWidth orientation:1];
			}
			
			if(!image) {
				image = [self imageWithView:self.attachmentView];
			}
			
			if(image) {
				animate([[UIImageView alloc] initWithImage:image], CGPointMake(i*2.5, i*2.5), i == total-1);
			}
		}
	} else {
		UIImage *image = nil;
		
		if([items[0] respondsToSelector:@selector(thumbnail)]) {
			image = [items[0] thumbnail];
		} else if([items[0] respondsToSelector:@selector(generateThumbnailForWidth:orientation:)]) {
			image = [items[0] generateThumbnailForWidth:self.defaultWidth orientation:1];
		}
		
		if(!image) {
			image = [self imageWithView:self.attachmentView];
		}
		
		if(image) {
			animate([[UIImageView alloc] initWithImage:image], CGPointMake(0, 0), YES);
		}
	}
	
	
	self.items += items.count;
}

@end
