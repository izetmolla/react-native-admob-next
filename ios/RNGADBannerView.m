#import "RNGADBannerView.h"
#import "RNAdMobUtils.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>
#else
#import "RCTBridgeModule.h"
#import "UIView+React.h"
#import "RCTLog.h"
#endif

#include "RCTConvert+GADAdSize.h"

@implementation RNGADBannerView
{
    GADBannerView *_bannerView;
}

- (void)dealloc
{
    _bannerView.delegate = nil;
    _bannerView.adSizeDelegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        super.backgroundColor = [UIColor clearColor];
        
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _bannerView.delegate = self;
        _bannerView.adSizeDelegate = self;
        _bannerView.rootViewController = rootViewController;
        [self addSubview:_bannerView];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    RCTLogError(@"RNGADBannerView cannot have subviews");
}
#pragma clang diagnostic pop

- (void)loadBanner
{
    if(self.onSizeChange) {
        CGSize size = CGSizeFromGADAdSize(_bannerView.adSize);
        if(!CGSizeEqualToSize(size, self.bounds.size)) {
            self.onSizeChange(@{
                                @"width": @(size.width),
                                @"height": @(size.height)
                                });
        }
    }
    
    GADRequest *request = [GADRequest request];
    [_bannerView loadRequest:request];
}

- (void)setTestDevices:(NSArray *)testDevices
{
    _testDevices = RNAdMobProcessTestDevices(testDevices, kGADSimulatorID);

    [GADMobileAds sharedInstance].requestConfiguration.testDeviceIdentifiers = _testDevices;
}

- (void)setAdSize:(NSString *)adSize
{
    _adSize = adSize;

    UIView *view = _bannerView.rootViewController.view;
    CGRect frame = view.frame;

    if (@available(iOS 11.0, *)) {
        frame = UIEdgeInsetsInsetRect(view.frame, view.safeAreaInsets);
    }

    [_bannerView setAdSize:[RCTConvert GADAdSize:_adSize withWidth:frame.size.width]];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _bannerView.frame = self.bounds;
}

# pragma mark GADBannerViewDelegate

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(__unused GADBannerView *)adView
{
   if (self.onAdLoaded) {
       self.onAdLoaded(@{});
   }
}

/// Tells the delegate an ad request failed.
- (void)adView:(__unused GADBannerView *)adView
didFailToReceiveAdWithError:(NSError *)error
{
    if (self.onAdFailedToLoad) {
        self.onAdFailedToLoad(@{ @"error": @{ @"message": [error localizedDescription] } });
    }
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(__unused GADBannerView *)adView
{
    if (self.onAdOpened) {
        self.onAdOpened(@{});
    }
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(__unused GADBannerView *)adView
{
    if (self.onAdClosed) {
        self.onAdClosed(@{});
    }
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(__unused GADBannerView *)adView
{
    if (self.onAdLeftApplication) {
        self.onAdLeftApplication(@{});
    }
}

# pragma mark GADAdSizeDelegate

/// Called before the ad view changes to the new size.
- (void)adView:(__unused GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size
{
    CGSize adSize = CGSizeFromGADAdSize(size);
    self.onSizeChange(@{
                              @"width": @(adSize.width),
                              @"height": @(adSize.height) });
}

@end
