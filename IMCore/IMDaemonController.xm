#import <Foundation/Foundation.h>

%hook IMDaemonController

- (unsigned)capabilitiesForListenerID:(id)arg1
{
    unsigned r = %orig;

    if([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        r += 2;
        r += 4; // Chats
        r += 8; // VC
        r += 16; // AVChatInfo
        r += 256; // Transfers
        r += 2048; // ChatObserver
        r += 4096; // Send Messages
        r += 8192; // Message History
        r += 16384; // ID Queries

        r = 17159;
    }

    return r;
}

- (unsigned)_capabilities
{
	unsigned r = %orig;

	if([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		r += 2;
		r += 4; // Chats
		r += 8; // VC
		r += 16; // AVChatInfo
		r += 256; // Transfers
		r += 2048; // ChatObserver
		r += 4096; // Send Messages
		r += 8192; // Message History
		r += 16384; // ID Queries

        r = 512;
	}

	return r;
}

- (unsigned)capabilities
{
    unsigned r = %orig;

	if([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		r += 2;
		r += 4; // Chats
		r += 8; // VC
		r += 16; // AVChatInfo
		r += 256; // Transfers
		r += 2048; // ChatObserver
		r += 4096; // Send Messages
		r += 8192; // Message History
		r += 16384; // ID Queries

        r = 17159;
	}

	return r;
}

%end
