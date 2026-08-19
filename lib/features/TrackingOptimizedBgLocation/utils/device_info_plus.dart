import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return info.id; // or info.serialNumber if appropriate (subject to Android restrictions)
  }

  if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return info.identifierForVendor ?? "unknown";
  }

  return "unknown";
}

Future<String> getAndroidId() async {
  const channel = MethodChannel('device_id');

  try {
    return await channel.invokeMethod<String>('getAndroidId') ?? '';
  } catch (e) {
    return '';
  }
}

