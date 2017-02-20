@interface IMPerson : NSObject

@property(nonatomic, retain, readonly) NSString *displayName; 

- (instancetype)initWithABRecordID:(int)recordID;

@end