import 'package:flutter/material.dart';

import 'features/Tour & Plans/TeritoryModule/screen/bihar_territory_test_screen.dart';

/// Launch with: flutter run -d emulator-5554 -t lib/main_bihar_territory_test.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BiharTerritoryPreview());
}

class _BiharTerritoryPreview extends StatelessWidget {
  const _BiharTerritoryPreview();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bihar Territory Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF317B72),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Bihar Territory Test')),
        body: const BiharTerritoryTestScreen(),
      ),
    );
  }
}
