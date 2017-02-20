@class IMPerson, IMService;

@interface IMHandle : NSObject

@property(nonatomic, retain, readonly) NSString *normalizedID;
@property(nonatomic, retain, readonly) IMService *service;

+ (NSArray*)imHandlesForIMPerson:(IMPerson*)person;
+ (instancetype)bestIMHandleInArray:(NSArray*)handles;

@end