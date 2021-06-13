#import "RNAdMobInterstitial.h"
#import "RNAdMobUtils.h"

#if __has_include(<React/RCTUtils.h>)
#import <React/RCTUtils.h>
#else
#import "RCTUtils.h"
#endif

static NSString *const kEventAdLoaded = @"interstitialAdLoaded";
static NSString *const kEventAdFailedToLoad = @"interstitialAdFailedToLoad";
static NSString *const kEventAdOpened = @"interstitialAdOpened";
static NSString *const kEventAdFailedToOpen = @"interstitialAdFailedToOpen";
static NSString *const kEventAdClosed = @"interstitialAdClosed";
static NSString *const kEventAdLeftApplication = @"interstitialAdLeftApplication";
static NSString *const kEventAdImpression = @"interstitialAdImpression";

@implementation RNAdMobInterstitial
{
    GADInterstitialAd  *_interstitial;
    NSString *_adUnitID;
    NSArray *_testDevices;
    BOOL hasListeners;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[
             kEventAdLoaded,
             kEventAdFailedToLoad,
             kEventAdOpened,
             kEventAdFailedToOpen,
             kEventAdClosed,
             kEventAdLeftApplication,
             kEventAdImpression ];
}

#pragma mark exported methods

RCT_EXPORT_METHOD(setAdUnitID:(NSString *)adUnitID)
{
    _adUnitID = adUnitID;
}

RCT_EXPORT_METHOD(setTestDevices:(NSArray *)testDevices)
{
    _testDevices = RNAdMobProcessTestDevices(testDevices, kGADSimulatorID);
}

RCT_EXPORT_METHOD(requestAd:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (_interstitial) {
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        BOOL hasBeenUsed = [_interstitial canPresentFromRootViewController:rootViewController error:nil];

        if (hasBeenUsed) {
            reject(@"E_AD_ALREADY_LOADED", @"Ad is already loaded.", nil);
            return;
        }
    }

    GADRequest *request = [GADRequest request];
    [GADInterstitialAd loadWithAdUnitID:_adUnitID
                                request:request
                      completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
        if (error) {
            if (self->hasListeners) {
                NSDictionary *jsError = RCTJSErrorFromCodeMessageAndNSError(@"E_AD_REQUEST_FAILED", error.localizedDescription, error);
                [self sendEventWithName:kEventAdFailedToLoad body:jsError];
            }

            reject(@"E_AD_REQUEST_FAILED", error.localizedDescription, error);

            return;
        }

        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter removeObserver:self
                                      name:UIApplicationDidEnterBackgroundNotification
                                    object:nil];

        [notificationCenter addObserver:self
                               selector:@selector(interstitialWillLeaveApplication:)
                                   name:UIApplicationDidEnterBackgroundNotification
                                 object:nil];

        self->_interstitial = interstitialAd;
        self->_interstitial.fullScreenContentDelegate = self;

        if (self->hasListeners) {
            [self sendEventWithName:kEventAdLoaded body:nil];
        }

        resolve(nil);
    }];
}

RCT_EXPORT_METHOD(showAd:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (!_interstitial) {
        reject(@"E_AD_NOT_READY", @"Ad is not ready.", nil);
        return;
    }

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    BOOL isReady = [_interstitial canPresentFromRootViewController:rootViewController error:nil];

    if (isReady) {
        [_interstitial presentFromRootViewController:rootViewController];

        resolve(nil);
    } else {
        reject(@"E_AD_NOT_READY", @"Ad is not ready.", nil);
    }
}

RCT_EXPORT_METHOD(isReady:(RCTResponseSenderBlock)callback)
{
    if (!_interstitial) {
        callback(@[[NSNumber numberWithBool:NO]]);
        return;
    }

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    BOOL isReady = [_interstitial canPresentFromRootViewController:rootViewController error:nil];

    callback(@[[NSNumber numberWithBool:isReady]]);
}

- (void)startObserving
{
    hasListeners = YES;
}

- (void)stopObserving
{
    hasListeners = NO;
}

#pragma mark GADFullScreenContentDelegate

/// Tells the delegate that an impression has been recorded for the ad.
- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad
{
    if (hasListeners) {
        [self sendEventWithName:kEventAdImpression body:nil];
    }
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error
{
    if (hasListeners) {
        [self sendEventWithName:kEventAdFailedToOpen body:nil];
    }
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad
{
    if (hasListeners) {
        [self sendEventWithName:kEventAdOpened body:nil];
    }
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad
{
    if (hasListeners) {
        [self sendEventWithName:kEventAdClosed body:nil];
    }
}

#pragma mark -

- (void)interstitialWillLeaveApplication:(NSNotification *)notification
{
    if (hasListeners) {
        [self sendEventWithName:kEventAdLeftApplication body:nil];
    }
}

@end
