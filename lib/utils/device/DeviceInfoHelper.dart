import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Future<String?> getDeviceId() async {
    String? deviceId;

    if (Platform.isAndroid) {
      // Fetch Android Device Info
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id; // Unique ID on Android
    } else if (Platform.isIOS) {
      // Fetch iOS Device Info
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      deviceId = iosInfo.identifierForVendor; // Unique ID on iOS
    }

    return deviceId;
  }
}
