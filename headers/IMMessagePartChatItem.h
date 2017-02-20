@interface IMMessagePartChatItem : NSObject

@property (nonatomic,copy,readonly) NSAttributedString * text;
@property (nonatomic,retain,readonly) IMMessage * message;

@end
