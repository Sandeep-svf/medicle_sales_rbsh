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
  String _currentTitle = TTexts.dashboard; // Initial title

  void _onMenuSelected(Widget screen, String title) {
    Navigator.of(context).pop(); // Close the drawer first
    setState(() {
      _currentScreen = screen;
      _currentTitle = title; // Assign the correct title
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(_currentTitle)),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
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
