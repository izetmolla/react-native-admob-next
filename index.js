/* eslint-disable global-require */
module.exports = {
  get AdMobBanner() {
    return require('./RNAdMobBanner').default;
  },
  get AdMobInterstitial() {
    return require('./RNAdMobInterstitial').default;
  },
  get PublisherBanner() {
    return require('./RNPublisherBanner').default;
  },
  get AdMobRewarded() {
    return require('./RNAdMobRewarded').default;
  },
  get AdSize() {
    return require('./RNAdSize').default;
  },
  get AdTestIds() {
    return require('./RNAdTestIds').default;
  }
};
