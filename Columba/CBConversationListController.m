//
//  CBConversationListController.m
//  
//
//  Created by Mohamed Marbouh on 2016-11-19.
//
//

#import "CBConversationListController.h"
#import "CBComposeViewController.h"
#import "CBAddressBarViewController.h"

@interface CBConversationListController ()

@property(nonatomic) NSArray *cellIdentifiers;
@property(nonatomic) NSMutableArray *orderedConversations;

@property(weak) CBComposeViewController *composeViewController;

@end

@implementation CBConversationListController

- (instancetype)init
{
	if((self = [super init])) {
		self.cellIdentifiers = @[@"CKConversationListCellIdentifier", @"CKConversationListCellGroupIdentifier"];
		self.orderedConversations = [NSMutableArray array];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = self.conversationCellHeight;
	self.tableView.tableHeaderView = nil;
	
	for(NSString *identifier in self.cellIdentifiers) {
		[self.tableView registerClass:CKConversationListCell.class forCellReuseIdentifier:identifier];
	}
	
	NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastFinishedMessageDate" ascending:NO];
	NSArray *chats = [[IMChatRegistry sharedInstance].allExistingChats sortedArrayUsingDescriptors:@[dateDescriptor]];
	
	for(IMChat *chat in chats) {
		CKConversation *conversation = [self.conversationList conversationForExistingChatWithGUID:chat.guid];
		
		[self.orderedConversations addObject:conversation];
	}
	
	if([self.delegate isKindOfClass:CBComposeViewController.class]) {
		self.composeViewController = (CBComposeViewController*)self.delegate;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	self.navigationController.navigationBar.translucent = YES;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.orderedConversations.count;
}

- (CKConversationListCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString *identifier = [CKConversationListCell identifierForConversation:self.orderedConversations[indexPath.row]];
	
	if(![self.cellIdentifiers containsObject:identifier]) {
		identifier = self.cellIdentifiers.firstObject;
	}
	
	CKConversationListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
		
	if(!cell) {
		cell = [[CKConversationListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	
	[cell updateContentsForConversation:self.orderedConversations[indexPath.row]];
	
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	CKConversationListCell *cell = (CKConversationListCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	
	if(self.delegate && [self.delegate.class conformsToProtocol:@protocol(CBConversationListControllerDelegate)]) {
		[self.delegate viewController:self selectedConversation:cell.conversation atIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return self.conversationCellHeight;
}

- (BOOL)searchBarShouldBeginEditing:(id)arg1
{
	self.navigationController.navigationBar.translucent = YES;
	
	return [super searchBarShouldBeginEditing:arg1];
}

- (void)searchBarTextDidEndEditing:(id)arg1
{
	self.navigationController.navigationBar.translucent = NO;
	
	[super searchBarTextDidEndEditing:arg1];
}

- (void)composeButtonClicked:(id)sender
{
	[self.composeViewController removeConversation];
	[self.navigationController popViewControllerAnimated:YES];
	[self.composeViewController performSelector:@selector(acceptRecipientInput) withObject:nil afterDelay:.7];
}

@end
