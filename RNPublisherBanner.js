import React, { Component } from 'react';
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle,
  ViewPropTypes,
} from 'react-native';
import { string, func, arrayOf } from 'prop-types';

import { createErrorFromErrorData } from './utils';

class PublisherBanner extends Component {
  constructor() {
    super();
    this.handleSizeChange = this.handleSizeChange.bind(this);
    this.handleAppEvent = this.handleAppEvent.bind(this);
    this.handleAdFailedToLoad = this.handleAdFailedToLoad.bind(this);
    this.state = {
      style: {},
    };
  }

  componentDidMount() {
    this.loadBanner();
  }

  loadBanner() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this._bannerView),
      UIManager.getViewManagerConfig('RNGAMBannerView').Commands.loadBanner,
      null,
    );
  }

  handleSizeChange(event) {
    const { height, width } = event.nativeEvent;
    this.setState({ style: { width, height } });
    if (this.props.onSizeChange) {
      this.props.onSizeChange({ width, height });
    }
  }

  handleAppEvent(event) {
    if (this.props.onAppEvent) {
      const { name, info } = event.nativeEvent;
      this.props.onAppEvent({ name, info });
    }
  }

  handleAdFailedToLoad(event) {
    if (this.props.onAdFailedToLoad) {
      this.props.onAdFailedToLoad(createErrorFromErrorData(event.nativeEvent.error));
    }
  }

  render() {
    return (
      <RNGAMBannerView
        {...this.props}
        style={[this.props.style, this.state.style]}
        onSizeChange={this.handleSizeChange}
        onAdFailedToLoad={this.handleAdFailedToLoad}
        onAppEvent={this.handleAppEvent}
        ref={el => (this._bannerView = el)}
      />
    );
  }
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

const RNGAMBannerView = requireNativeComponent('RNGAMBannerView',PublisherBanner);

export default PublisherBanner;
