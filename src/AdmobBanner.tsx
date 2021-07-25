import React, { FC, useEffect, useRef, useState } from "react";
import {
    requireNativeComponent,
    UIManager,
    findNodeHandle,
} from "react-native";

import { createErrorFromErrorData } from "./utils";

type AdmobBannerTypes = {
    style?: any | {};
    onSizeChange?: any;
    onAdFailedToLoad?: any;
    adSize?: string;
    adUnitID?: string;
    testDevices?: any;
    onAdLoaded?: any;
    onAdRecordImpression?: any;
    onAdOpened?: any;
    onAdClosed?: any;
    simulatorId?: string | "SIMULATOR";
};
const AdmobBanner: FC<AdmobBannerTypes> = ({
    style,
    onSizeChange,
    onAdFailedToLoad,
    ...res
}) => {
    const _bannerView: any = useRef(null);
    const [custonStyle, setCustomStyle]: any = useState({});
    useEffect(() => {
        loadBanner();
    });

    const loadBanner = () => {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(_bannerView),
            UIManager.getViewManagerConfig("RNGADBannerView").Commands
                .loadBanner,
            undefined
        );
    };
    const handleSizeChange = (event: any) => {
        const { height, width } = event.nativeEvent;
        setCustomStyle({ width, height });
        if (onSizeChange) {
            onSizeChange({ width, height });
        }
    };
    const handleAdFailedToLoad = (event: any) => {
        if (onAdFailedToLoad) {
            onAdFailedToLoad(createErrorFromErrorData(event.nativeEvent.error));
        }
    };
    return (
        <RNGADBannerView
            {...res}
            style={[style, custonStyle]}
            onSizeChange={handleSizeChange}
            onAdFailedToLoad={handleAdFailedToLoad}
            ref={_bannerView}
        />
    );
};

AdmobBanner.simulatorId = "SIMULATOR";

const RNGADBannerView = requireNativeComponent("RNGADBannerView");

export default AdmobBanner;
