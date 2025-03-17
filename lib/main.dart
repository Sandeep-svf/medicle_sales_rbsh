import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart'; // Import your App widget

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalesController()),
      ],
      child: const App(),
    ),
  );
}
