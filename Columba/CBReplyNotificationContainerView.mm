//
//  CBReplyNotificationContainerView.mm
//  
//
//  Created by Mohamed Marbouh on 2016-09-29.
//
//

#import "CBReplyNotificationContainerView.h"
#import "../headers/headers.h"

#import "CBChat.h"

#import <substrate.h>

@interface CBReplyNotificationContainerView ()

@property(weak) UIDateLabel *dateLabel;

@end

@implementation CBReplyNotificationContainerView

- (instancetype)initWithConversation:(CKConversation*)conversation bulletin:(BBBulletin*)bulletin
{
	if((self = [super init])) {
		[ColumbaUI makeAutoLayout:self];
		
		self.cell = [[CKConversationListCell alloc] initWithStyle:0 reuseIdentifier:@"CKConversationListCellIdentifier"];
		
		[self.cell updateContentsForConversation:conversation];
		
		NSArray *conversationContacts = conversation.orderedContactsForAvatarView;
		
		if(conversationContacts.count == 1) {
			self.cell.avatarView = [[CKAvatarView alloc] initWithContact:conversationContacts[0]];
		} else if(conversationContacts.count > 1) {
			self.cell.avatarView = [[CKAvatarView alloc] init];
			self.cell.avatarView.contacts = conversationContacts;
		}
		
		[ColumbaUI removeAllConstraints:self.cell.avatarView];
		[ColumbaUI makeAutoLayout:self.cell.avatarView];
		
		self.dateLabel = MSHookIvar<UIDateLabel*>(self.cell, "_dateLabel");
		self.dateLabel.date = bulletin.date;
		
		[ColumbaUI removeAllConstraints:self.dateLabel];
		[ColumbaUI makeAutoLayout:self.dateLabel];
		
		self.fromLabel = MSHookIvar<UILabel*>(self.cell, "_fromLabel");
		self.fromLabel.text = bulletin.content.title;
		
		[ColumbaUI removeAllConstraints:self.fromLabel];
		[ColumbaUI makeAutoLayout:self.fromLabel];
        
        CKTextMessagePartChatItem *item = [[CKTextMessagePartChatItem alloc] initWithIMChatItem:[CBChat chatItemFromBulletin:bulletin] maxWidth:CGRectGetWidth(self.frame)];
		
		self.summaryText = [[UITextView alloc] init];
		self.summaryText.backgroundColor = [UIColor clearColor];
		self.summaryText.editable = NO;
        
        NSLog(@"item: %@", item);
        NSLog(@"responds: %hhd", (char)[item respondsToSelector:@selector(loadTranscriptText)]);
        NSLog(@"bulletin: %@", bulletin.content.message);
        
        if(item && [item respondsToSelector:@selector(loadTranscriptText)]) {
            NSLog(@"transcript: %@", item.loadTranscriptText);
            self.summaryText.attributedText = item.loadTranscriptText;
        } else {
            self.summaryText.text = bulletin.content.message;
        }
        
        self.summaryText.textAlignment = NSTextAlignmentCenter;
		
		[ColumbaUI makeAutoLayout:self.summaryText];
		
		[self addSubview:self.cell.avatarView];
		[self addSubview:self.fromLabel];
		[self addSubview:self.dateLabel];
		[self addSubview:self.summaryText];
		
		[self setupConstraints];
	}
	
	return self;
}

- (NSUInteger)numberNewLinesInString:(NSString*)string
{
	return [[string componentsSeparatedByString:@"\n"] count] - 1;
}

- (CGSize)sizeForMessageInBounds:(CGSize)bounds
{	
	CGSize result = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
	result.height += [self.summaryText sizeThatFits:bounds].height;
	
	return result;
}

- (void)setupConstraints
{
	NSArray *monogramConstraints = @[[NSLayoutConstraint constraintWithItem:self.cell.avatarView.imageButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:8],
								   [NSLayoutConstraint constraintWithItem:self.cell.avatarView.imageButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
	
	NSArray *summaryConstraints = @[[NSLayoutConstraint constraintWithItem:self.summaryText attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
									[NSLayoutConstraint constraintWithItem:self.summaryText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cell.avatarView.imageButton attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
									[NSLayoutConstraint constraintWithItem:self.summaryText attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
									[NSLayoutConstraint constraintWithItem:self.summaryText attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
	
	NSArray *fromConstraints = @[[NSLayoutConstraint constraintWithItem:self.fromLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.cell.avatarView.imageButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:8],
								 [NSLayoutConstraint constraintWithItem:self.fromLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.dateLabel attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
								 [NSLayoutConstraint constraintWithItem:self.fromLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.cell.avatarView.imageButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	
	NSArray *dateConstraints = @[[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.fromLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
								 [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.fromLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	
	NSArray *selfConstraints = @[[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.summaryText attribute:NSLayoutAttributeBottom multiplier:1 constant:8],
								 [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.dateLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8]];
	
	[self addConstraints:monogramConstraints];
	[self addConstraints:summaryConstraints];
	[self addConstraints:fromConstraints];
	[self addConstraints:dateConstraints];
	[self addConstraints:selfConstraints];
}

@end

