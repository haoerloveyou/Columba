@interface SBLockScreenManager : NSObject

@property(readonly) BOOL isUILocked;

+ (instancetype)sharedInstance;

@end