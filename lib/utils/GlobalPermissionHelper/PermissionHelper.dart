// lib/utils/permission_helper.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Checks and requests camera + gallery/storage permissions at runtime.
  /// Fully compatible with Android 7–16 and iOS.
  static Future<bool> checkAndRequestMediaPermissions() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      if (sdkInt >= 33) {
        //  Android 13+ (API 33+) uses new granular permissions
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.camera,
        ].request();

        return statuses.values.every((status) => status.isGranted);
      } else {
        //  Android 7–12 (API < 33) use legacy storage + camera
        final statuses = await [
          Permission.storage,
          Permission.camera,
        ].request();

        return statuses.values.every((status) => status.isGranted);
      }
    } else if (Platform.isIOS) {
      //  iOS media permissions
      final statuses = await [
        Permission.photos,
        Permission.camera,
      ].request();
      return statuses.values.every((status) => status.isGranted);
    } else {
      //  Web / Desktop – skip permissions
      return true;
    }
  }

  /// Opens system settings if user permanently denies permission
  static Future<void> openAppSettingsIfDenied() async {
    final allPerms = [
      Permission.photos,
      Permission.videos,
      Permission.storage,
      Permission.camera,
    ];

    for (var perm in allPerms) {
      if (await perm.isPermanentlyDenied) {
        await openAppSettings();
        break;
      }
    }
  }

  /// Gets the Android SDK version using device_info_plus (safe alternative)
  static Future<int> _getAndroidSdkInt() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt;
      }
    } catch (_) {}
    return 30; // Default to Android 11 if unknown
  }
}
