#import "headers/headers.h"
#import "headers/libMobileGestalt.h"
#include <netdb.h>
#import <arpa/inet.h>
#import <ifaddrs.h>

static int paymentStatus = -1;
static NSString *udidString = nil;

NSString *udid()
{
	if(!udidString) {
		CFPropertyListRef value = MGCopyAnswer(kMGUniqueDeviceID);
		udidString = (__bridge NSString*)value;
		CFRelease(value);
	}
	
	return udidString;
}

BOOL isInternetAvailable()
{
	struct addrinfo *res = NULL;
	int s = getaddrinfo("mootjeuh.com", NULL, NULL, &res);
	BOOL network_ok = (s == 0 && res != NULL);
	freeaddrinfo(res);
	
	return network_ok;
}

void checkForPayment(void(^completed)(BOOL))
{
	if(paymentStatus == -1) {
		if(isInternetAvailable()) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
				NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
				NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
				NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://columba.mootjeuh.com/drm/check.php?pkg=com.mootjeuh.columba9&udid=%@", udid()]];
				
				NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
																	   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
																   timeoutInterval:25];
				
				[request setHTTPMethod:@"GET"];
				
				NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
					BOOL isOK = YES;
					
					if(data && data.bytes) {
						NSString *responseString = [NSString stringWithUTF8String:data.bytes];
						
						if([responseString isEqualToString:@"-1"]) {
							isOK = NO;
						}
					}
					
					paymentStatus = isOK ? 0 : 1;
					
					dispatch_async(dispatch_get_main_queue(), ^{
						completed(isOK);
					});
				}];
				
				[getDataTask resume];
			});
		} else {
			completed(YES);
		}
	} else if(paymentStatus == 0) {
		completed(YES);
	} else if(paymentStatus == 1) {
		completed(NO);
	}
}
