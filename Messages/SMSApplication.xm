#import "../headers/headers.h"

@interface CKMessagesController : UISplitViewController

- (void)showConversation:(CKConversation*)conversation animate:(BOOL)animate;

@end

@interface SMSApplication : UIApplication

@property(retain, nonatomic) CKMessagesController *messagesController;

- (CKConversation*)CB_conversationFromContacts:(NSArray*)contacts create:(BOOL)create;
- (MFComposeRecipient*)CB_recipientFromDictionaryEntry:(NSDictionary*)dictionary;

@end

%hook SMSApplication

%new
- (MFComposeRecipient*)CB_recipientFromDictionaryEntry:(NSDictionary*)dictionary
{
    CNContact *contact = [%c(CNContact) contactWithIdentifier:dictionary[@"id"]];
    MSHookIvar<int>(contact, "_iOSLegacyIdentifier") = [dictionary[@"abId"] intValue];

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;

    NSNumber *kind = [f numberFromString:dictionary[@"kind"]];
    NSNumber *sourceType = [f numberFromString:dictionary[@"sourceType"]];

    MFComposeRecipient *recipient = [[%c(MFComposeRecipient) alloc] initWithContact:contact address:dictionary[@"address"] kind:kind.unsignedLongLongValue];
    recipient.contact = contact;
    recipient.displayString = dictionary[@"displayString"];
    recipient.sourceType = sourceType.unsignedLongLongValue;

    return recipient;
}

%new
- (CKConversation*)CB_conversationFromContacts:(NSArray*)contacts create:(BOOL)create
{
    NSMutableArray *handles = [NSMutableArray array];
    NSString *displayName = @"";

    for(NSDictionary *contact in contacts) {
        MFComposeRecipient *recipient = [self CB_recipientFromDictionaryEntry:contact];
        IMPerson *person = [[%c(IMPerson) alloc] initWithABRecordID:recipient.contact.iOSLegacyIdentifier];

        if(contacts.count > 1) {
            if(displayName.length == 0) {
                displayName = person.displayName;
            } else {
                displayName = [displayName stringByAppendingString:[NSString stringWithFormat:@", %@", person.displayName]];
            }
        } else {
            displayName = person.displayName;
        }

        NSArray *contactHandles = [%c(IMHandle) imHandlesForIMPerson:person];
        NSMutableArray *temp = [NSMutableArray array];

        for(IMHandle *contactHandle in contactHandles) {
            if([contactHandle.service isEqual:[%c(IMService) iMessageService]] || [contactHandle.service isEqual:[%c(IMService) smsService]]) {
                if([contactHandle.normalizedID isEqualToString:recipient.normalizedAddress]) {
                    [temp addObject:contactHandle];
                }
            }
        }

        if(temp.count >= 1) {
            [handles addObject:[%c(IMHandle) bestIMHandleInArray:temp]];
        }
    }

    return [[%c(CKConversationList) sharedConversationList] conversationForHandles:handles displayName:displayName joinedChatsOnly:NO create:create];
}

- (void)handleURL:(NSURL*)url
{
    if([url.host isEqualToString:@"columba"]) {
        NSString *string = [[url.absoluteString componentsSeparatedByString:@"sms://columba/"] lastObject];
        string = string.stringByRemovingPercentEncoding;

        NSDictionary *info = string.propertyListFromStringsFileFormat;

        if([info.allKeys containsObject:@"recipients"]) {
            BOOL success = NO;
            NSArray *recipients = info[@"recipients"];

            if(recipients.count > 0) {
                CKConversation *conversation = [self CB_conversationFromContacts:recipients create:NO];

                if(conversation) {
                    success = YES;
                    [self.messagesController showConversation:conversation animate:YES];
                }
            }

            if(!success) {
                %orig;
            }
        } else if([info.allKeys containsObject:@"conversation"]) {
            CKConversation *conversation = [[%c(CKConversationList) sharedConversationList] conversationForExistingChatWithGUID:info[@"conversation"]];

            [self.messagesController showConversation:conversation animate:YES];
        }
    } else {
        %orig;
    }
}

%end
