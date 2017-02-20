//
//  CBSocialMediator.m
//  
//
//  Created by Mohamed Marbouh on 2016-11-01.
//
//

#import "../headers/headers.h"
#import "CBColour.h"

#import "CBSocialMediator.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface CBSocialMediator () <GADBannerViewDelegate>

@property(nonatomic) GADBannerView *bannerView;
@property(nonatomic) UIButton *button;

@end

@implementation CBSocialMediator

+ (instancetype)sharedInstance
{
	static CBSocialMediator *sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self.class alloc] init];
		
		[GADMobileAds configureWithApplicationID:@"ca-app-pub-4721921609958243~7785447615"];
	});
	
	return sharedInstance;
}

- (void)viewDidLoad
{
	if(!self.bannerView) {
		self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
	}
	
	self.bannerView.delegate = self;
	self.bannerView.adUnitID = @"ca-app-pub-4721921609958243/9262180811";
	self.bannerView.rootViewController = self.viewController;
	
	GADRequest *request = [GADRequest request];
	request.testDevices = @[@"39ac091fb2ff56802038dd5d76300809"];
	[self.bannerView loadRequest:request];
}

- (void)adViewDidReceiveAd:(GADBannerView*)bannerView
{
	self.view = bannerView;
}

- (void)adView:(GADBannerView*)bannerView didFailToReceiveAdWithError:(GADRequestError*)error
{
	NSDictionary *attributes = @{NSForegroundColorAttributeName: CBColour.blue, NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
	NSString *message = COLUMBA_STRING(@"DRM.Message", @"Please buy Columba");
	
	self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.button addTarget:self action:@selector(tappedButton) forControlEvents:UIControlEventTouchUpInside];
	[self.button setAttributedTitle:[[NSAttributedString alloc] initWithString:message attributes:attributes] forState:UIControlStateNormal];
	
	self.view = self.button;
}

- (void)adViewWillPresentScreen:(GADBannerView*)bannerView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)adViewWillDismissScreen:(GADBannerView*)bannerView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)adViewDidDismissScreen:(GADBannerView*)bannerView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)adViewWillLeaveApplication:(GADBannerView*)bannerView
{
	[[CBActivatorListener sharedInstance] dismissWindowIfPossible];
}

- (void)tappedButton
{
	[[CBActivatorListener sharedInstance] dismissWindowIfPossible];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.mootjeuh.columba9"]];
}

@end
