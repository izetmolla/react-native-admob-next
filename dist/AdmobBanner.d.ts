import { FC } from "react";
declare type AdmobBannerTypes = {
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
declare const AdmobBanner: FC<AdmobBannerTypes>;
export default AdmobBanner;
