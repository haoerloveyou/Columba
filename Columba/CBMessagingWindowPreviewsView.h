//
//  CBMessagingWindowPreviewsView.h
//  
//
//  Created by Mohamed Marbouh on 2016-10-12.
//
//

#import <UIKit/UIKit.h>

@interface CBMessagingWindowPreviewsView : UIView

- (void)messagingViewController:(CBMessagingWindowViewController*)viewController processItems:(NSArray*)items completion:(void (^)())block;

@end
