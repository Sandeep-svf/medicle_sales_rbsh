import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/LocationHelper/backgrond_services.dart';
import 'package:medicle_sales_rbsh/utils/LocationHelper/background_task.dart';
import 'package:provider/provider.dart';
import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart'; // Import your App widget

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService.initialize(); // Initialize background service
  await BackgroundService.startService(); // Start background service

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalesController()),
      ],
      child: const App(),
    ),
  );
}
