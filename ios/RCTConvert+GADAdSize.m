#import "RCTConvert+GADAdSize.h"

@implementation RCTConvert (GADAdSize)

+ (GADAdSize)GADAdSize:(id)json withWidth:(CGFloat)width
{
    NSString *adSize = [self NSString:json];
    if ([adSize isEqualToString:@"banner"]) {
        return kGADAdSizeBanner;
    } else if ([adSize isEqualToString:@"fullBanner"]) {
        return kGADAdSizeFullBanner;
    } else if ([adSize isEqualToString:@"largeBanner"]) {
        return kGADAdSizeLargeBanner;
    } else if ([adSize isEqualToString:@"fluid"]) {
        return kGADAdSizeFluid;
    } else if ([adSize isEqualToString:@"skyscraper"]) {
        return kGADAdSizeSkyscraper;
    } else if ([adSize isEqualToString:@"leaderboard"]) {
        return kGADAdSizeLeaderboard;
    } else if ([adSize isEqualToString:@"mediumRectangle"]) {
        return kGADAdSizeMediumRectangle;
    } else if ([adSize isEqualToString:@"adaptiveBanner"]) {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width);
    }
    else {
        return kGADAdSizeInvalid;
    }
}

@end
