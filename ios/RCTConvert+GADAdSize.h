#import <React/RCTConvert.h>
@import GoogleMobileAds;

@interface RCTConvert (GADAdSize)

+ (GADAdSize)GADAdSize:(id)json withWidth:(CGFloat)width;

@end
