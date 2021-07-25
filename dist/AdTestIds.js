import { Platform } from 'react-native';
export default {
    ...Platform.select({
        android: {
            BANNER: 'ca-app-pub-3940256099942544/6300978111',
            INTERSTITIAL: 'ca-app-pub-3940256099942544/1033173712',
            REWARDED: 'ca-app-pub-3940256099942544/5224354917',
        },
        ios: {
            BANNER: 'ca-app-pub-3940256099942544/2934735716',
            INTERSTITIAL: 'ca-app-pub-3940256099942544/4411468910',
            REWARDED: 'ca-app-pub-3940256099942544/1712485313',
        },
    }),
};
