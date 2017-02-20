@interface IMChat : NSObject

@property(nonatomic, readonly) NSString *guid;
@property(nonatomic, retain, readonly) NSDate *lastFinishedMessageDate;

- (NSArray*)chatItems;
- (void)deleteChatItems:(NSArray*)chatItems;

@end
