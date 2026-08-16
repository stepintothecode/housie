# Release builds shrink and obfuscate. These keep the plugin entry points the
# platform calls by name, which the shrinker cannot see being used.

# Flutter engine and plugin registration.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Text to speech. The Android engine calls back into these listeners.
-keep class com.tundralabs.fluttertts.** { *; }

# Keeps line numbers in a Play crash report, which is the whole point of
# uploading the mapping file.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
