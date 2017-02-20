@interface CKComposition : NSObject

@property(nonatomic, copy) NSAttributedString *text;

- (instancetype)initWithText:(NSAttributedString*)text subject:(NSString*)subject;
- (instancetype)compositionByAppendingMediaObjects:(NSArray*)mediaObjects;

@end