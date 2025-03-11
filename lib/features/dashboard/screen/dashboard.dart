import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/Screen/salesChartHome.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import '../widgets/custrom_drawer.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget _currentScreen = SalesChartHomeScreen(); // Default screen

  void _onMenuSelected(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
    Navigator.of(context).pop(); // Close the drawer after selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TTexts.dashboard),
        leading: Builder( // Wrap with Builder to access Scaffold.of(context)
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Correctly opens the drawer
              },
            );
          },
        ),
      ),
      drawer: CustomDrawer(onMenuSelected: _onMenuSelected),
      body: _currentScreen,
    );
  }
}
