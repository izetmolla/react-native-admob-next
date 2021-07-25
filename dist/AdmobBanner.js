import React, { useEffect, useRef, useState } from "react";
import { requireNativeComponent, UIManager, findNodeHandle, } from "react-native";
import { createErrorFromErrorData } from "./utils";
const AdmobBanner = ({ style, onSizeChange, onAdFailedToLoad, ...res }) => {
    const _bannerView = useRef(null);
    const [custonStyle, setCustomStyle] = useState({});
    useEffect(() => {
        loadBanner();
    });
    const loadBanner = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(_bannerView), UIManager.getViewManagerConfig("RNGADBannerView").Commands
            .loadBanner, undefined);
    };
    const handleSizeChange = (event) => {
        const { height, width } = event.nativeEvent;
        setCustomStyle({ width, height });
        if (onSizeChange) {
            onSizeChange({ width, height });
        }
    };
    const handleAdFailedToLoad = (event) => {
        if (onAdFailedToLoad) {
            onAdFailedToLoad(createErrorFromErrorData(event.nativeEvent.error));
        }
    };
    return (React.createElement(RNGADBannerView, { ...res, style: [style, custonStyle], onSizeChange: handleSizeChange, onAdFailedToLoad: handleAdFailedToLoad, ref: _bannerView }));
};
AdmobBanner.simulatorId = "SIMULATOR";
const RNGADBannerView = requireNativeComponent("RNGADBannerView");
export default AdmobBanner;
