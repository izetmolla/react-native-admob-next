import React, { useEffect, useState, useRef } from "react";
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle,
  ViewPropTypes,
} from "react-native";
import { string, func, arrayOf } from "prop-types";

import { createErrorFromErrorData } from "./utils";
function PublisherBanner(props) {
  const viewRef = useRef();
  const [style, setStyle] = useState({});

  useEffect(() => {
    loadBanner();
  }, []);

  const loadBanner = () => {
    const node = findNodeHandle(viewRef.current);
    // console.log('BANNER LOAD', node, props)
    UIManager.dispatchViewManagerCommand(
      node,
      UIManager.getViewManagerConfig("RNGAMBannerView").Commands.loadBanner,
      []
    );
  };

  const handleSizeChange = (event) => {
    const { height, width } = event.nativeEvent;
    const newStyle = { width: Math.round(width), height: Math.round(height) };
    if (JSON.stringify(style) !== JSON.stringify(newStyle)) {
      const node = findNodeHandle(viewRef.current);
      // console.log('BANNER STYLE', node,newStyle);
      setStyle(newStyle);
      props.onSizeChange?.(newStyle);
    }
  };

  const handleAppEvent = (event) => {
    if (props.onAppEvent) {
      const { name, info } = event.nativeEvent;
      props.onAppEvent({ name, info });
    }
  };

  const handleAdFailedToLoad = (event) => {
    if (props.onAdFailedToLoad) {
      props.onAdFailedToLoad(createErrorFromErrorData(event.nativeEvent.error));
    }
  };

  return (
    <RNGAMBannerView
      {...props}
      style={[props.style, style]}
      onSizeChange={handleSizeChange}
      onAdFailedToLoad={handleAdFailedToLoad}
      onAppEvent={handleAppEvent}
      ref={(ref) => (viewRef.current = ref)}
    />
  );
}

PublisherBanner.simulatorId = "SIMULATOR";

PublisherBanner.propTypes = {
  ...ViewPropTypes,

  /**
   * DFP iOS library banner size constants
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
   * Optional array specifying all valid sizes that are appropriate for this slot.
   */
  validAdSizes: arrayOf(string),

  /**
   * DFP ad unit ID
   */
  adUnitID: string,

  /**
   * Array of test devices. Use PublisherBanner.simulatorId for the simulator
   */
  testDevices: arrayOf(string),
  onSizeChange: func,

  /**
   * DFP library events
   */
  onAdLoaded: func,
  onAdFailedToLoad: func,
  onAdOpened: func,
  onAdClosed: func,
  onAppEvent: func,
};

const RNGAMBannerView = requireNativeComponent(
  "RNGAMBannerView",
  PublisherBanner
);

export default PublisherBanner;
