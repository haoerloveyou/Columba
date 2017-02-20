#import "../headers/headers.h"
#import "../Columba/CBAddressBarViewController.h"

%hook CKRecipientSearchListController

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = %orig;

    if([self.delegate isKindOfClass:CBAddressBarViewController.class]) {
        tableView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
    }

    return cell;
}

%end
