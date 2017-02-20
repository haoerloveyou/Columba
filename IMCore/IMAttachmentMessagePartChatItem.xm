#import <Foundation/Foundation.h>

%hook IMAttachmentMessagePartChatItem

%new
- (NSAttributedString*)subject
{
	return objc_getAssociatedObject(self, @selector(subject));
}

%new
- (void)setSubject:(NSAttributedString*)value
{
	objc_setAssociatedObject(self, @selector(subject), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end
