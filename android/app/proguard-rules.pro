 -ignorewarnings
 -keep class * {
     public private *;
 }

 # Prevent obfuscation of Material Components (including Drawer)
 -keep class androidx.appcompat.widget.** { *; }
 -keep class androidx.drawerlayout.widget.** { *; }

