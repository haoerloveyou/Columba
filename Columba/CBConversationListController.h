//
//  CBConversationListController.h
//  
//
//  Created by Mohamed Marbouh on 2016-11-19.
//
//

#import "../headers/headers.h"

@protocol CBConversationListControllerDelegate <NSObject>

@required
- (void)viewController:(UIViewController*)viewController selectedConversation:(CKConversation*)conversation atIndexPath:(NSIndexPath*)indexPath;

@end

@interface CBConversationListController : CKConversationListController

@property(nonatomic, retain) id<CBConversationListControllerDelegate> delegate;

@end
