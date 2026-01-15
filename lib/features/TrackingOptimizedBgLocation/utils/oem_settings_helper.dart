import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';

class OemSettingsHelper {
  static Future<void> open() async {
    if (!Platform.isAndroid) return;

    final intents = [
      // Xiaomi
      AndroidIntent(
        action: 'miui.intent.action.POWER_HIDE_MODE_APP_LIST',
      ),

      // Oppo / Realme
      AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      ),

      // Samsung
      AndroidIntent(
        action: 'android.settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      ),

      // Fallback
      AndroidIntent(
        action: 'android.settings.SETTINGS',
      ),
    ];

    for (final intent in intents) {
      try {
        await intent.launch();
        break;
      } catch (_) {
        // try next
      }
    }
  }
}
