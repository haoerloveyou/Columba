//
//  CBReplyNotificationContainerView.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-29.
//
//

#import <UIKit/UIKit.h>

@class CKConversation, BBBulletin, CKConversationListCell;

@interface CBReplyNotificationContainerView : UIView

@property(nonatomic) CKConversationListCell *cell;
@property(weak) UILabel *fromLabel;
@property(nonatomic) UITextView *summaryText;

- (instancetype)initWithConversation:(CKConversation*)conversation bulletin:(BBBulletin*)bulletin;
- (CGSize)sizeForMessageInBounds:(CGSize)bounds;

@end
