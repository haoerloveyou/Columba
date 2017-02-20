@interface MFComposeRecipient : NSObject

@property(nonatomic, retain) CNContact *contact;
@property(nonatomic, readonly) NSString *normalizedAddress;
@property(nonatomic,readonly) NSUInteger kind;
@property(assign, nonatomic) NSUInteger sourceType;
@property(nonatomic, retain) NSString *displayString;

- (instancetype)initWithContact:(CNContact*)contact address:(NSString*)arg2 kind:(NSUInteger)arg3;
- (NSString*)address;

@end