//
//  CBTemplatesTableViewController.h
//  
//
//  Created by Mohamed Marbouh on 2016-09-23.
//
//

#import <UIKit/UIKit.h>

@protocol CBTemplatesTableViewControllerDelegate <NSObject>

@required
- (void)viewController:(UIViewController*)viewController selectedTemplate:(NSString*)templateText atIndexPath:(NSIndexPath*)indexPath;

@end

@interface CBTemplatesTableViewController : UITableViewController

@property(nonatomic, retain) id<CBTemplatesTableViewControllerDelegate> delegate;

@end
