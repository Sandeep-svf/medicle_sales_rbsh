 -ignorewarnings
 -keep class * {
     public private *;
 }

 # Prevent obfuscation of Material Components (including Drawer)
 -keep class androidx.appcompat.widget.** { *; }
 -keep class androidx.drawerlayout.widget.** { *; }


 -keep class com.almoullim.background_locator_2.** { *; }
 -keep class com.almoullim.background_locator_2.callback.** { *; }


