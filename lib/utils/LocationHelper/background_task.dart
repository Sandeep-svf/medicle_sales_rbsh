import 'dart:async';
import 'package:workmanager/workmanager.dart';

import 'LocationServices.dart';

class BackgroundTask {
  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false in production
    );
  }

  static void startFetchingLocation() {
    Workmanager().registerPeriodicTask(
      "fetch_location_task",
      "fetchLocation",
      frequency: const Duration(minutes: 15), // Runs every 15 minutes
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await LocationService.fetchLocation(); // Now works without context
    return Future.value(true);
  });
}
