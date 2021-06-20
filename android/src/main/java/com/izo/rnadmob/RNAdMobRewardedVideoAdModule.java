package com.izo.rnadmob;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableNativeArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.OnUserEarnedRewardListener;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.AdRequest;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

public class RNAdMobRewardedVideoAdModule extends ReactContextBaseJavaModule {

    public static final String REACT_CLASS = "RNAdMobRewarded";

    public static final String EVENT_AD_LOADED = "rewardedVideoAdLoaded";
    public static final String EVENT_AD_FAILED_TO_LOAD = "rewardedVideoAdFailedToLoad";
    public static final String EVENT_AD_OPENED = "rewardedVideoAdOpened";
    public static final String EVENT_AD_FAILED_TO_OPEN = "rewardedVideoAdFailedToOpen";
    public static final String EVENT_AD_CLOSED = "rewardedVideoAdClosed";
    public static final String EVENT_REWARDED = "rewardedVideoAdRewarded";
    public static final String EVENT_AD_IMPRESSION = "rewardedVideoAdImpression";

    RewardedAd mRewardedAd;
    String adUnitID;
    String[] testDevices;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    public RNAdMobRewardedVideoAdModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    private void sendEvent(String eventName, @Nullable WritableMap params) {
        getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
    }

    @ReactMethod
    public void setAdUnitID(String adUnitID) {
        this.adUnitID = adUnitID;
    }

    @ReactMethod
    public void setTestDevices(ReadableArray testDevices) {
      ReadableNativeArray nativeArray = (ReadableNativeArray)testDevices;
      ArrayList<Object> list = nativeArray.toArrayList();
      this.testDevices = list.toArray(new String[list.size()]);

      if (testDevices != null) {
            List<String> testDeviceIds = new ArrayList<>();

            for (int i = 0; i < this.testDevices.length; i++) {
                String testDevice = this.testDevices[i];
                if (testDevice == "SIMULATOR") {
                    testDeviceIds.add(AdRequest.DEVICE_ID_EMULATOR);
                } else {
                    testDeviceIds.add(testDevice);
                }
            }

            RequestConfiguration configuration = new RequestConfiguration.Builder().setTestDeviceIds(testDeviceIds).build();
            MobileAds.setRequestConfiguration(configuration);
        }
    }

    @ReactMethod
    public void requestAd(final Promise promise) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (mRewardedAd != null) {
                    promise.reject("E_AD_ALREADY_LOADED", "Ad is already loaded.");
                    return;
                }

                FullScreenContentCallback fullScreenContentCallback = new FullScreenContentCallback() {
                    @Override
                    public void onAdFailedToShowFullScreenContent(@NonNull @NotNull AdError adError) {
                        super.onAdFailedToShowFullScreenContent(adError);

                        sendEvent(EVENT_AD_FAILED_TO_OPEN, null);
                    }

                    @Override
                    public void onAdShowedFullScreenContent() {
                        super.onAdShowedFullScreenContent();

                        sendEvent(EVENT_AD_OPENED, null);
                    }

                    @Override
                    public void onAdDismissedFullScreenContent() {
                        super.onAdDismissedFullScreenContent();

                        sendEvent(EVENT_AD_CLOSED, null);
                    }

                    @Override
                    public void onAdImpression() {
                        super.onAdImpression();

                        sendEvent(EVENT_AD_IMPRESSION, null);
                    }
                };

                RewardedAdLoadCallback rewardedAdLoadCallback = new RewardedAdLoadCallback() {
                    @Override
                    public void onAdLoaded(@NonNull @NotNull RewardedAd rewardedAd) {
                        super.onAdLoaded(rewardedAd);

                        mRewardedAd = rewardedAd;
                        mRewardedAd.setFullScreenContentCallback(fullScreenContentCallback);

                        sendEvent(EVENT_AD_LOADED, null);

                        promise.resolve(null);
                    }

                    @Override
                    public void onAdFailedToLoad(@NonNull @NotNull LoadAdError loadAdError) {
                        super.onAdFailedToLoad(loadAdError);

                        int errorCode = loadAdError.getCode();

                        String errorString = "ERROR_UNKNOWN";
                        String errorMessage = "Unknown error";

                        switch (errorCode) {
                            case AdRequest.ERROR_CODE_INTERNAL_ERROR:
                              errorString = "ERROR_CODE_INTERNAL_ERROR";
                              errorMessage = "Internal error, an invalid response was received from the ad server.";
                              break;
                            case AdRequest.ERROR_CODE_INVALID_REQUEST:
                              errorString = "ERROR_CODE_INVALID_REQUEST";
                              errorMessage = "Invalid ad request, possibly an incorrect ad unit ID was given.";
                              break;
                            case AdRequest.ERROR_CODE_NETWORK_ERROR:
                              errorString = "ERROR_CODE_NETWORK_ERROR";
                              errorMessage = "The ad request was unsuccessful due to network connectivity.";
                              break;
                            case AdRequest.ERROR_CODE_NO_FILL:
                              errorString = "ERROR_CODE_NO_FILL";
                              errorMessage = "The ad request was successful, but no ad was returned due to lack of ad inventory.";
                              break;
                        }

                        WritableMap event = Arguments.createMap();
                        event.putString("message", errorMessage);
                        sendEvent(EVENT_AD_FAILED_TO_LOAD, event);

                        promise.reject(errorString, errorMessage);
                    }
                };

                AdRequest.Builder adRequestBuilder = new AdRequest.Builder();
                AdRequest adRequest = adRequestBuilder.build();

                RewardedAd.load(getCurrentActivity(), adUnitID, adRequest, rewardedAdLoadCallback);
            }
        });
    }

    @ReactMethod
    public void showAd(final Promise promise) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (mRewardedAd != null) {
                    mRewardedAd.show(getCurrentActivity(), new OnUserEarnedRewardListener() {
                        @Override
                        public void onUserEarnedReward(@NonNull @NotNull RewardItem rewardItem) {
                            WritableMap reward = Arguments.createMap();

                            reward.putInt("amount", rewardItem.getAmount());
                            reward.putString("type", rewardItem.getType());

                            sendEvent(EVENT_REWARDED, reward);
                        }
                    });

                    promise.resolve(null);
                } else {
                    promise.reject("E_AD_NOT_READY", "Ad is not ready.");
                }
            }
        });
    }

    @ReactMethod
    public void isReady(final Callback callback) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (mRewardedAd != null) {
                    callback.invoke(true);
                } else {
                    callback.invoke(false);
                }
            }
        });
    }
}
