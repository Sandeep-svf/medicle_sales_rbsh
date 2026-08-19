import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SamsungBatterySettings {
  SamsungBatterySettings._();

  static const MethodChannel _channel =
  MethodChannel('samsung_battery_settings');

  // ============================================================
  // CHECK SAMSUNG DEVICE
  // ============================================================

  static Future<bool> isSamsungDevice() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final result =
      await _channel.invokeMethod<bool>(
        'isSamsung',
      );

      final isSamsung = result ?? false;

      debugPrint(
        '[SAMSUNG_BATTERY] isSamsung = $isSamsung',
      );

      return isSamsung;
    } catch (e) {
      debugPrint(
        '[SAMSUNG_BATTERY] isSamsung error: $e',
      );

      return false;
    }
  }

  // ============================================================
  // SLEEPING APPS
  //
  // Samsung activity_type = 0
  // ============================================================

  static Future<bool> openSleepingApps() async {
    return _openBatteryList(
      activityType: 0,
      name: 'Sleeping apps',
    );
  }

  // ============================================================
  // DEEP SLEEPING APPS
  //
  // Samsung activity_type = 1
  // ============================================================

  static Future<bool> openDeepSleepingApps() async {
    return _openBatteryList(
      activityType: 1,
      name: 'Deep sleeping apps',
    );
  }

  // ============================================================
  // NEVER AUTO SLEEPING APPS
  //
  // Samsung activity_type = 2
  // ============================================================

  static Future<bool> openNeverSleepingApps() async {
    return _openBatteryList(
      activityType: 2,
      name: 'Never sleeping apps',
    );
  }

  // ============================================================
  // COMMON METHOD
  // ============================================================

  static Future<bool> _openBatteryList({
    required int activityType,
    required String name,
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      debugPrint(
        '[SAMSUNG_BATTERY] Opening $name...',
      );

      final result =
      await _channel.invokeMethod<bool>(
        'openSamsungBatteryList',
        {
          'activity_type': activityType,
        },
      );

      debugPrint(
        '[SAMSUNG_BATTERY] '
            '$name open result = $result',
      );

      return result ?? false;
    } catch (e, s) {
      debugPrint(
        '[SAMSUNG_BATTERY] '
            'Failed to open $name: $e',
      );

      debugPrint('$s');

      return false;
    }
  }
}