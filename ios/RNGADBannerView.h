#if __has_include(<React/RCTView.h>)
#import <React/RCTView.h>
#else
#import "RCTView.h"
#endif

@import GoogleMobileAds;

@class RCTEventDispatcher;

@interface RNGADBannerView : RCTView <GADBannerViewDelegate, GADAdSizeDelegate>

@property (nonatomic, copy) NSArray *testDevices;
@property (nonatomic, copy) NSString *adSize;
@property (nonatomic, copy) NSDictionary *customTargeting;

@property (nonatomic, copy) RCTBubblingEventBlock onAdLoaded;
@property (nonatomic, copy) RCTBubblingEventBlock onAdFailedToLoad;
@property (nonatomic, copy) RCTBubblingEventBlock onAdRecordImpression;
@property (nonatomic, copy) RCTBubblingEventBlock onAdOpened;
@property (nonatomic, copy) RCTBubblingEventBlock onAdClosed;
@property (nonatomic, copy) RCTBubblingEventBlock onSizeChange;

- (void)loadBanner;

@end
