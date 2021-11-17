package com.izo.rnadmob;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableNativeArray;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.facebook.react.views.view.ReactViewGroup;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.admanager.AdManagerAdView;
import com.google.android.gms.ads.admanager.AppEventListener;
import com.google.android.gms.ads.admanager.AdManagerAdRequest;
import com.google.android.gms.ads.AdSize;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

class ReactPublisherAdView extends ReactViewGroup implements AppEventListener {

    protected AdManagerAdView adView;

    String[] testDevices;
    AdSize[] validAdSizes;
    String adUnitID;
    AdSize adSize;    
    ReadableMap customTargeting;

    public ReactPublisherAdView(final Context context) {
        super(context);
        this.createAdView();
    }

    private void createAdView() {
        if (this.adView != null) this.adView.destroy();

        final Context context = getContext();
        this.adView = new AdManagerAdView(context);
        this.adView.setAppEventListener(this);
        this.adView.setAdListener(new AdListener() {
            @Override
            public void onAdClosed() {
                super.onAdClosed();

                sendEvent(RNPublisherBannerViewManager.EVENT_AD_CLOSED, null);
            }

            @Override
            public void onAdFailedToLoad(@NonNull @NotNull LoadAdError loadAdError) {
                super.onAdFailedToLoad(loadAdError);

                int errorCode = loadAdError.getCode();

                String errorMessage = "Unknown error";
                switch (errorCode) {
                    case AdManagerAdRequest.ERROR_CODE_INTERNAL_ERROR:
                        errorMessage = "Internal error, an invalid response was received from the ad server.";
                        break;
                    case AdManagerAdRequest.ERROR_CODE_INVALID_REQUEST:
                        errorMessage = "Invalid ad request, possibly an incorrect ad unit ID was given.";
                        break;
                    case AdManagerAdRequest.ERROR_CODE_NETWORK_ERROR:
                        errorMessage = "The ad request was unsuccessful due to network connectivity.";
                        break;
                    case AdManagerAdRequest.ERROR_CODE_NO_FILL:
                        errorMessage = "The ad request was successful, but no ad was returned due to lack of ad inventory.";
                        break;
                }
                WritableMap event = Arguments.createMap();
                WritableMap error = Arguments.createMap();
                error.putString("message", errorMessage);
                event.putMap("error", error);
                sendEvent(RNPublisherBannerViewManager.EVENT_AD_FAILED_TO_LOAD, event);
            }

            @Override
            public void onAdOpened() {
                super.onAdOpened();

                sendEvent(RNPublisherBannerViewManager.EVENT_AD_OPENED, null);
            }

            @Override
            public void onAdLoaded() {
                super.onAdLoaded();

                int width = adView.getAdSize().getWidthInPixels(context);
                int height = adView.getAdSize().getHeightInPixels(context);
                int left = adView.getLeft();
                int top = adView.getTop();
                adView.measure(width, height);
                adView.layout(left, top, left + width, top + height);
                sendOnSizeChangeEvent();
                sendEvent(RNPublisherBannerViewManager.EVENT_AD_LOADED, null);
            }

            @Override
            public void onAdClicked() {
                super.onAdClicked();
            }

            @Override
            public void onAdImpression() {
                super.onAdImpression();

                sendEvent(RNAdMobBannerViewManager.EVENT_AD_RECORD_IMPRESSION, null);
            }
        });
        this.addView(this.adView);
    }

    private void sendOnSizeChangeEvent() {
        int width;
        int height;
        WritableMap event = Arguments.createMap();
        AdSize adSize = this.adView.getAdSize();

        width = adSize.getWidth();
        height = adSize.getHeight();

        event.putDouble("width", width);
        event.putDouble("height", height);
        sendEvent(RNAdMobBannerViewManager.EVENT_SIZE_CHANGE, event);
    }

    private void sendEvent(String name, @Nullable WritableMap event) {
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                        getId(),
                        name,
                        event);
    }

    public void loadBanner() {
        ArrayList<AdSize> adSizes = new ArrayList<AdSize>();
        if (this.adSize != null) {
            adSizes.add(this.adSize);
        }
        if (this.validAdSizes != null) {
            for (int i = 0; i < this.validAdSizes.length; i++) {
                adSizes.add(this.validAdSizes[i]);
            }
        }

        if (adSizes.size() == 0) {
            adSizes.add(AdSize.BANNER);
        }

        AdSize[] adSizesArray = adSizes.toArray(new AdSize[adSizes.size()]);
        this.adView.setAdSizes(adSizesArray);

        AdManagerAdRequest.Builder adRequestBuilder = new AdManagerAdRequest.Builder();
        AdManagerAdRequest adRequest = adRequestBuilder.build();
        if (this.customTargeting != null) {
            ReadableMapKeySetIterator iterator = this.customTargeting.keySetIterator();
            while (iterator.hasNextKey()) {
                String key = iterator.nextKey();
                ReadableArray value = this.customTargeting.getArray(key);
                List<String> values = new ArrayList<String>();
                for(int i = 0; i < value.size(); i++){
                    values.add(value.getString(i));
                }
                adRequest = adRequest.addCustomTargeting(key, values);
            }
        }
        this.adView.loadAd(adRequest);
    }

    public void setAdUnitID(String adUnitID) {
        if (this.adUnitID != null) {
            // We can only set adUnitID once, so when it was previously set we have
            // to recreate the view
            this.createAdView();
        }
        this.adUnitID = adUnitID;
        this.adView.setAdUnitId(adUnitID);
    }

    public void setTestDevices(String[] testDevices) {
        this.testDevices = testDevices;

        if (testDevices != null) {
            List<String> testDeviceIds = new ArrayList<>();

            for (int i = 0; i < testDevices.length; i++) {
                String testDevice = testDevices[i];
                if (testDevice == "SIMULATOR") {
                    testDeviceIds.add(AdManagerAdRequest.DEVICE_ID_EMULATOR);
                } else {
                    testDeviceIds.add(testDevice);
                }
            }

            RequestConfiguration configuration = new RequestConfiguration.Builder().setTestDeviceIds(testDeviceIds).build();
            MobileAds.setRequestConfiguration(configuration);
        }
    }

    public void setAdSize(AdSize adSize) {
        this.adSize = adSize;
    }

    public void setValidAdSizes(AdSize[] adSizes) {
        this.validAdSizes = adSizes;
    }

    public void setCustomTargeting(ReadableMap _customTargeting) {
        this.customTargeting = _customTargeting;
    }

    @Override
    public void onAppEvent(String name, String info) {
        WritableMap event = Arguments.createMap();
        event.putString("name", name);
        event.putString("info", info);
        sendEvent(RNPublisherBannerViewManager.EVENT_APP_EVENT, event);
    }
}

public class RNPublisherBannerViewManager extends ViewGroupManager<ReactPublisherAdView> {

    public static final String REACT_CLASS = "RNGADBannerView";

    public static final String PROP_AD_SIZE = "adSize";
    public static final String PROP_VALID_AD_SIZES = "validAdSizes";
    public static final String PROP_AD_UNIT_ID = "adUnitID";
    public static final String PROP_TEST_DEVICES = "testDevices";    
    public static final String PROP_CUSTOM_TARGETING = "customTargeting";

    public static final String EVENT_AD_LOADED = "onAdLoaded";
    public static final String EVENT_AD_FAILED_TO_LOAD = "onAdFailedToLoad";
    public static final String EVENT_AD_RECORD_IMPRESSION = "onAdRecordImpression";
    public static final String EVENT_AD_OPENED = "onAdOpened";
    public static final String EVENT_AD_CLOSED = "onAdClosed";
    public static final String EVENT_SIZE_CHANGE = "onSizeChange";
    public static final String EVENT_APP_EVENT = "onAppEvent";

    public static final int COMMAND_LOAD_BANNER = 1;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected ReactPublisherAdView createViewInstance(ThemedReactContext themedReactContext) {
        ReactPublisherAdView adView = new ReactPublisherAdView(themedReactContext);
        return adView;
    }

    @Override
    public void addView(ReactPublisherAdView parent, View child, int index) {
        throw new RuntimeException("RNPublisherBannerView cannot have subviews");
    }

    @Override
    @Nullable
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
        String[] events = {
            EVENT_AD_LOADED,
            EVENT_AD_FAILED_TO_LOAD,
            EVENT_AD_RECORD_IMPRESSION,
            EVENT_AD_OPENED,
            EVENT_AD_CLOSED,
            EVENT_SIZE_CHANGE,
            EVENT_APP_EVENT
        };
        for (int i = 0; i < events.length; i++) {
            builder.put(events[i], MapBuilder.of("registrationName", events[i]));
        }
        return builder.build();
    }

    @ReactProp(name = PROP_AD_SIZE)
    public void setPropAdSize(final ReactPublisherAdView view, final String sizeString) {
        Context context = view.getContext();
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = windowManager.getDefaultDisplay();
        DisplayMetrics outMetrics = new DisplayMetrics();
        display.getMetrics(outMetrics);

        float widthPixels = outMetrics.widthPixels;
        float density = outMetrics.density;

        int adWidth = (int) (widthPixels / density);

        AdSize adSize = getAdSizeFromString(context, sizeString, adWidth);
        view.setAdSize(adSize);
    }

    @ReactProp(name = PROP_VALID_AD_SIZES)
    public void setPropValidAdSizes(final ReactPublisherAdView view, final ReadableArray adSizeStrings) {
        Context context = view.getContext();
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = windowManager.getDefaultDisplay();
        DisplayMetrics outMetrics = new DisplayMetrics();
        display.getMetrics(outMetrics);

        float widthPixels = outMetrics.widthPixels;
        float density = outMetrics.density;

        int adWidth = (int) (widthPixels / density);

        ReadableNativeArray nativeArray = (ReadableNativeArray)adSizeStrings;
        ArrayList<Object> list = nativeArray.toArrayList();
        String[] adSizeStringsArray = list.toArray(new String[list.size()]);
        AdSize[] adSizes = new AdSize[list.size()];

        for (int i = 0; i < adSizeStringsArray.length; i++) {
                String adSizeString = adSizeStringsArray[i];
                adSizes[i] = getAdSizeFromString(context, adSizeString, adWidth);
        }
        view.setValidAdSizes(adSizes);
    }

    @ReactProp(name = PROP_AD_UNIT_ID)
    public void setPropAdUnitID(final ReactPublisherAdView view, final String adUnitID) {
        view.setAdUnitID(adUnitID);
    }

    @ReactProp(name = PROP_CUSTOM_TARGETING)
    public void setPropCustomTargeting(final ReactPublisherAdView view, final ReadableMap customTargeting) {
        view.setCustomTargeting(customTargeting);
    }

    @ReactProp(name = PROP_TEST_DEVICES)
    public void setPropTestDevices(final ReactPublisherAdView view, final ReadableArray testDevices) {
        ReadableNativeArray nativeArray = (ReadableNativeArray)testDevices;
        ArrayList<Object> list = nativeArray.toArrayList();
        view.setTestDevices(list.toArray(new String[list.size()]));
    }

    private AdSize getAdSizeFromString(Context context, String adSize, int width) {
        switch (adSize) {
            case "largeBanner":
                return AdSize.LARGE_BANNER;
            case "mediumRectangle":
                return AdSize.MEDIUM_RECTANGLE;
            case "fullBanner":
                return AdSize.FULL_BANNER;
            case "leaderboard":
                return AdSize.LEADERBOARD;
            case "adaptiveBanner":
                return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(context, width);
            default:
                return AdSize.BANNER;
        }
    }

    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of("loadBanner", COMMAND_LOAD_BANNER);
    }

    @Override
    public void receiveCommand(ReactPublisherAdView root, int commandId, @javax.annotation.Nullable ReadableArray args) {
        switch (commandId) {
            case COMMAND_LOAD_BANNER:
                root.loadBanner();
                break;
        }
    }
}
