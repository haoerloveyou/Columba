@interface CNContactStoreDataSource : NSObject

@property(nonatomic, readonly) NSArray *contacts;

- (instancetype)initWithStore:(CNContactStore*)store;

@end