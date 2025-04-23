import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicle_sales_rbsh/utils/LocationHelper/on_start.dart';
import 'package:provider/provider.dart';
import 'features/addClinic/controllers/ClinicListController.dart';
import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart'; // Import your App widget


/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeBackgroundService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalesController()),
      ],
      child: const App(),
    ),
  );
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'location_channel', // Required for Android 10+
      initialNotificationTitle: 'Tracking Location',
      initialNotificationContent: 'Location service is running',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(), // Not needed for Android-only
  );

  await service.startService();
}*/


void main() async{

  /*debugPrint('LocationTag: A.');
  WidgetsFlutterBinding.ensureInitialized();// Required for async operations before runApp
  debugPrint('LocationTag: Initializing background service...');
  await BackgroundLocationService.requestPermissions(); // Request permissions and start service
*/

  debugPrint('LocationTag: B');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalesController()),
      ],
      child: const App(),
    ),
  );
}
