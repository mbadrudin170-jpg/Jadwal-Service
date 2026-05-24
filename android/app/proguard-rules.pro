# Flutter-specific additions.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.**  { *; }

# Firebase and AdMob rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.ads.initialization.OnInitializationCompleteListener { *; }
-keep class com.google.android.gms.ads.rewarded.RewardedAd { *; }
-keep class com.google.android.gms.ads.rewarded.RewardedAdLoadCallback { *; }
-keep class com.google.android.gms.ads.interstitial.InterstitialAd { *; }
-keep class com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback { *; }
-keep class com.google.android.gms.ads.appopen.AppOpenAd { *; }
-keep class com.google.android.gms.ads.appopen.AppOpenAd$AppOpenAdLoadCallback { *; }

# Keep the Ad Manager App ID in the manifest.
-keep_strings /resources/string/com.google.android.gms.ads.APPLICATION_ID

# For Google Mobile Ads SDK, if you are using ProGuard.
-keep public class com.google.android.gms.ads.admanager.AdManagerAdRequest$Builder {
    public com.google.android.gms.ads.admanager.AdManagerAdRequest$Builder addCustomTargeting(java.lang.String, java.lang.String);
    public com.google.android.gms.ads.admanager.AdManagerAdRequest build();
}

-keep public class com.google.android.gms.ads.admanager.AdManagerAdRequest {
    public java.util.Map getCustomTargeting();
}

# Workaround for https://issuetracker.google.com/186221199
-keep class androidx.work.impl.utils.SynchronousExecutor
-keep class androidx.work.impl.utils.taskexecutor.TaskExecutor
