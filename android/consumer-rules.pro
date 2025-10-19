# --- Keep important attributes used by reflection / annotations
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,EnclosingMethod
-keepattributes *Annotation*

# --- Infobip SDK public API (avoid stripping things end-apps might touch)
-keep public class org.infobip.mobile.messaging.** { public protected *; }
-keep public interface org.infobip.mobile.messaging.api.** { public *; }
-keep public enum org.infobip.mobile.messaging.api.** { *; }

# --- Core model objects commonly (de)serialized or reflected upon
-keep class org.infobip.mobile.messaging.Installation { *; }
-keep class org.infobip.mobile.messaging.Message { *; }
-keep class org.infobip.mobile.messaging.User { *; }
-keep class org.infobip.mobile.messaging.CustomAttributeValue { *; }
-keep class org.infobip.mobile.messaging.interactive.NotificationAction { *; }
-keep class org.infobip.mobile.messaging.interactive.NotificationAction$* { *; }
-keep class org.infobip.mobile.messaging.interactive.NotificationCategory { *; }
-keep class org.infobip.mobile.messaging.cloud.hms.HmsMessageMapper { *; }
-keep class org.infobip.mobile.messaging.cloud.hms.HmsMessageMapper$* { *; }
-keep class org.infobip.mobile.messaging.mobileapi.** { *; }

# --- Enums (some SDKs reflect on enum names)
-keepclassmembers class org.infobip.mobile.messaging.** extends java.lang.Enum {
    <fields>;
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keep public enum org.infobip.mobile.messaging.** { *; }

# --- Native methods (if any) shouldn't be stripped
-keepclasseswithmembernames class org.infobip.mobile.messaging.** {
    native <methods>;
}

# --- Gson adapters and factories (so @JsonAdapter and runtime registration work)
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# --- Common 3rd-party keep/dontwarn used by Infobip/HMS stacks
-dontwarn lombok.**
-dontwarn sun.misc.Unsafe

# --- Huawei kits used by the SDK (avoid over-shrinking HMS classes)
-keep class com.huawei.hianalytics.** { *; }
-keep class com.huawei.updatesdk.** { *; }
-keep class com.huawei.hms.** { *; }
-keep class com.huawei.android.** { *; }
-keep class com.huawei.agconnect.** { *; }
-keep class com.huawei.libcore.** { *; }