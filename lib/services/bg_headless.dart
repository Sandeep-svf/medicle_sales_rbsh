/*
import 'package:flutter/foundation.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

@pragma('vm:entry-point')
void bgHeadless(bg.HeadlessEvent e) async {
  if (kReleaseMode) {
    // Keep it lightweight in release.
  }
  switch (e.name) {
    case bg.Event.HEARTBEAT:
      try {
        await bg.BackgroundGeolocation.getCurrentPosition(
          samples: 1,
          extras: {'event': 'heartbeat', 'headless': true},
        );
      } catch (_) {}
      break;
    case bg.Event.TERMINATE:
    // Optional: record one last fix.
      try {
        await bg.BackgroundGeolocation.getCurrentPosition(
          samples: 1,
          extras: {'event': 'terminate', 'headless': true},
        );
      } catch (_) {}
      break;
    default:
    // You can switch on other events if needed.
      break;
  }
}
*/
