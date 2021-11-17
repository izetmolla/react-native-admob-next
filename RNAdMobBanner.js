import React, { useEffect, useState } from "react";
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle,
  ViewPropTypes,
} from "react-native";
import { string, func, arrayOf } from "prop-types";

import { createErrorFromErrorData } from "./utils";
function AdMobBanner(props) {
  const [style, setStyle] = useState({});

  useEffect(() => {
    loadBanner();
  }, []);

  const loadBanner = () => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(_bannerView),
      UIManager.getViewManagerConfig("RNGADBannerView").Commands.loadBanner,
      []
    );
  };

  const handleSizeChange = (event) => {
    const { height, width } = event.nativeEvent;
    setStyle({ width, height });
    if (props.onSizeChange) {
      props.onSizeChange({ width, height });
    }
  };

  const handleAdFailedToLoad = (event) => {
    if (props.onAdFailedToLoad) {
      props.onAdFailedToLoad(createErrorFromErrorData(event.nativeEvent.error));
    }
  };

  return (
    <RNGADBannerView
      {...props}
      style={[props.style, style]}
      onSizeChange={handleSizeChange}
      onAdFailedToLoad={handleAdFailedToLoad}
      ref={(el) => (_bannerView = el)}
    />
  );
}

AdMobBanner.simulatorId = "SIMULATOR";

AdMobBanner.propTypes = {
  ...ViewPropTypes,

  /**
   * AdMob iOS library banner size constants
   * (https://developers.google.com/admob/ios/banner)
   * banner (320x50, Standard Banner for Phones and Tablets)
   * largeBanner (320x100, Large Banner for Phones and Tablets)
   * mediumRectangle (300x250, IAB Medium Rectangle for Phones and Tablets)
   * fullBanner (468x60, IAB Full-Size Banner for Tablets)
   * leaderboard (728x90, IAB Leaderboard for Tablets)
   * adaptiveBannerPortrait (Screen width x Adaptive height, Adaptive Banner for Phones and Tablets)
   * adaptiveBannerLandscape (Screen width x Adaptive height, Adaptive Banner for Phones and Tablets)
   *
   * banner is default
   */
  adSize: string,

  /**
   * AdMob ad unit ID
   */
  adUnitID: string,

  /**
   * Array of test devices. Use AdMobBanner.simulatorId for the simulator
   */
  testDevices: arrayOf(string),

  /**
   * AdMob iOS library events
   */
  onSizeChange: func,

  onAdLoaded: func,
  onAdFailedToLoad: func,
  onAdRecordImpression: func,
  onAdOpened: func,
  onAdClosed: func,
};

const RNGADBannerView = requireNativeComponent("RNGADBannerView", AdMobBanner);

export default AdMobBanner;
