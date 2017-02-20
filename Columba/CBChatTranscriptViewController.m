//
//  CBChatTranscriptViewController.m
//  
//
//  Created by Mohamed Marbouh on 2016-09-20.
//
//

#import "CBChatTranscriptViewController.h"

@implementation CBChatTranscriptViewController

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

@end
