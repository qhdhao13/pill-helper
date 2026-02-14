# Flutter ProGuard 规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 保持本地通知功能
-keep class com.dexterous.** { *; }
-keep class me.carda.awesome_notifications.** { *; }

# 保持 SQLite 功能
-keep class net.sqlcipher.** { *; }
-keep class com.tekartik.sqflite.** { *; }

# 保持图片选择功能
-keep class io.flutter.plugins.imagepicker.** { *; }

# 保持权限处理功能
-keep class com.baseflow.permissionhandler.** { *; }

# 保持路径提供者功能
-keep class io.flutter.plugins.pathprovider.** { *; }

# 保持 SharedPreferences 功能
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# 混淆后保持方法名
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile
-keepattributes LineNumberTable

# 保持应用类
-keep class com.example.pill_helper.** { *; }
