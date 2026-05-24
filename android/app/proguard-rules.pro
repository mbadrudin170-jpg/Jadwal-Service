# Flutter wrapper -> Don't edit. 
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Google Mobile Ads SDK
-keep public class com.google.android.gms.ads.** {
   public *;
}

-keep public class com.google.ads.mediation.** {
   public *;
}

# Required by the Google Mobile Ads SDK
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Signature

-keep class com.google.android.gms.common.util.DynamiteApi {
    public *;
}

-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info {
    public *;
}

