#import "RNAdMobRewarded.h"
#import "RNAdMobUtils.h"

#if __has_include(<React/RCTUtils.h>)
#import <React/RCTUtils.h>
#else
#import "RCTUtils.h"
#endif

static NSString *const kEventAdLoaded = @"rewardedVideoAdLoaded";
static NSString *const kEventAdFailedToLoad = @"rewardedVideoAdFailedToLoad";
static NSString *const kEventAdOpened = @"rewardedVideoAdOpened";
static NSString *const kEventAdFailedToOpen = @"rewardedVideoAdFailedToOpen";
static NSString *const kEventAdClosed = @"rewardedVideoAdClosed";
static NSString *const kEventRewarded = @"rewardedVideoAdRewarded";
static NSString *const kEventAdImpression = @"rewardedVideoAdImpression";

@implementation RNAdMobRewarded
{
    NSString *_adUnitID;
    NSArray *_testDevices;
    GADRewardedAd *_rewardedAd;
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
             kEventRewarded,
             kEventAdLoaded,
             kEventAdFailedToLoad,
             kEventAdOpened,
             kEventAdFailedToOpen,
             kEventAdClosed,
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
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:_adUnitID
                            request:request
                  completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
        if (error) {
            if (self->hasListeners) {
                NSDictionary *jsError = RCTJSErrorFromCodeMessageAndNSError(@"E_AD_FAILED_TO_LOAD", error.localizedDescription, error);
                [self sendEventWithName:kEventAdFailedToLoad body:jsError];
            }

            reject(@"E_AD_FAILED_TO_LOAD", error.localizedDescription, error);

            return;
        }

        self->_rewardedAd = rewardedAd;
        self->_rewardedAd.fullScreenContentDelegate = self;

        if (self->hasListeners) {
            [self sendEventWithName:kEventAdLoaded body:nil];
        }

        resolve(nil);
    }];
}

RCT_EXPORT_METHOD(showAd:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (!_rewardedAd) {
        reject(@"E_AD_NOT_READY", @"Ad is not ready.", nil);
        return;
    }

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    BOOL isReady = [_rewardedAd canPresentFromRootViewController:rootViewController error:nil];

    if (isReady) {
        [_rewardedAd presentFromRootViewController:rootViewController
            userDidEarnRewardHandler:^{
            GADAdReward *reward = self->_rewardedAd.adReward;

            if (self->hasListeners) {
                [self sendEventWithName:kEventRewarded body:@{@"type": reward.type, @"amount": reward.amount}];
            }
        }];

        resolve(nil);
    } else {
        reject(@"E_AD_NOT_READY", @"Ad is not ready.", nil);
    }
}

RCT_EXPORT_METHOD(isReady:(RCTResponseSenderBlock)callback)
{
    if (!_rewardedAd) {
        callback(@[[NSNumber numberWithBool:NO]]);
        return;
    }

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    BOOL isReady = [_rewardedAd canPresentFromRootViewController:rootViewController error:nil];

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

@end
