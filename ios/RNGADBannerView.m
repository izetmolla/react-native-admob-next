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
    request.customTargeting = self.customTargeting;
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

/// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
/// the banner view to the view hierarchy if it hasn't been added yet.
- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView
{
    if (self.onAdLoaded) {
        self.onAdLoaded(@{});
    }
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)bannerView:(nonnull GADBannerView *)bannerView
    didFailToReceiveAdWithError:(nonnull NSError *)error
{
    if (self.onAdFailedToLoad) {
        self.onAdFailedToLoad(@{ @"error": @{ @"message": [error localizedDescription] } });
    }
}

/// Tells the delegate that an impression has been recorded for an ad.
- (void)bannerViewDidRecordImpression:(nonnull GADBannerView *)bannerView
{
    if (self.onAdRecordImpression) {
        self.onAdRecordImpression(@{});
    }
}

/// Tells the delegate that a full screen view will be presented in response to the user clicking on
/// an ad. The delegate may want to pause animations and time sensitive interactions.
- (void)bannerViewWillPresentScreen:(nonnull GADBannerView *)bannerView
{
    if (self.onAdOpened) {
        self.onAdOpened(@{});
    }
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)bannerViewWillDismissScreen:(nonnull GADBannerView *)bannerView
{
    if (self.onAdClosed) {
        self.onAdClosed(@{});
    }
}

# pragma mark GADAdSizeDelegate

/// Called before the ad view changes to the new size.
- (void)adView:(nonnull GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size
{
    CGSize adSize = CGSizeFromGADAdSize(size);
    self.onSizeChange(@{
        @"width": @(adSize.width),
        @"height": @(adSize.height)
                      });
}

@end
