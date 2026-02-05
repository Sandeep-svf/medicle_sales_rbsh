import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPermissionHelper {

  /// Request camera permission
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request storage ONLY for Android ≤ 12
  static Future<bool> requestGalleryIfNeeded() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdk = androidInfo.version.sdkInt;

    // Android 13+ → NO permission required
    if (sdk >= 33) return true;

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestCameraAndGallery() async {
    final cam = await requestCamera();
    final gal = await requestGalleryIfNeeded();
    return cam && gal;
  }

  static Future<bool> isPermanentlyDenied() async {
    return await Permission.camera.isPermanentlyDenied ||
        await Permission.storage.isPermanentlyDenied;
  }
}
