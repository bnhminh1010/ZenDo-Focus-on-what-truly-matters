# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Keep Supabase classes
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# Keep Google Sign-In classes
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Firebase classes (if used)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Gson classes (for JSON serialization)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep model classes (prevent obfuscation of data models)
-keep class com.example.zendo_app.models.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep annotation classes
-keepattributes *Annotation*

# Keep generic signatures
-keepattributes Signature

# Keep inner classes
-keepattributes InnerClasses

# Keep exception classes
-keep public class * extends java.lang.Exception

# Prevent obfuscation of classes with native methods
-keepclasseswithmembernames class * {
    native <methods>;
}