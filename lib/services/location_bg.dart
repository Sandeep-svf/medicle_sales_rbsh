import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';

const _portName = 'bg_location_port';

@pragma('vm:entry-point')
void locationCallback(LocationDto data) {
  IsolateNameServer.lookupPortByName(_portName)?.send(data);
}

@pragma('vm:entry-point')
void initCallback(dynamic _) {}

@pragma('vm:entry-point')
void disposeCallback() {}

@pragma('vm:entry-point')
void notificationCallback() {}

class BgLocation {
  static Future<void> start() async {
    await BackgroundLocator.initialize();
    await BackgroundLocator.registerLocationUpdate(
      locationCallback,
      initCallback: initCallback,
      disposeCallback: disposeCallback,
      androidSettings: const AndroidSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        interval: 5000,               // ms
        distanceFilter: 0,            // meters; bump up to save battery
        client: LocationClient.google,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationChannelName: 'Location tracking',
          notificationTitle: 'Tracking active',
          notificationMsg: 'Location service is running',
          notificationTapCallback: notificationCallback,
        ),
      ),
      iosSettings: const IOSSettings(), // ignored on Android
      autoStop: false,
    );
  }

  static Future<void> stop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }
}
