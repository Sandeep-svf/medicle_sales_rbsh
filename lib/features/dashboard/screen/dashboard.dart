import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/Screen/salesChartHome.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../Blog/screen/blog.dart';
import '../../Inbox/Screen/InboxScreen.dart';
import '../../MarketingMaterials/Screens/MarketingMaterials.dart';
import '../../marketing/screen/marketing.dart';
import '../../notification/NotificatinScreen.dart';
import '../widgets/custrom_drawer.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget _currentScreen = SalesChartHomeScreen(); // Default screen
  PageController controller = PageController(initialPage: 0);
  int selectedIndex = 0;
  String _currentTitle = TTexts.dashboard; // Initial title

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onMenuSelected(Widget screen, String title) {
    Navigator.of(context).pop(); // Close the drawer
    setState(() {
      _currentTitle = title;
      _currentScreen = screen;
    });
  }

  List<Widget> _buildScreens() => [
    SalesChartHomeScreen(),
    MarketingScreen(),
    MarketingmaterialsScreen(),
    Blogscreen(),
    InboxScreen()
  ];


  List<BottomBarItem> _navBarsItems() => [
    BottomBarItem(
      icon: const Icon(Icons.home),
      selectedIcon: const Icon(Icons.home_filled),
      selectedColor: TColors.primary,
      unSelectedColor: Colors.grey,
      title: const Text('Home'),
    ),
    BottomBarItem(
      icon: const Icon(Icons.folder),
      selectedIcon: const Icon(Icons.folder_open),
      selectedColor: TColors.primary,
      unSelectedColor: Colors.grey,
      title: const Text('Files & PDFs'),
    ),
    BottomBarItem(
      icon: const Icon(Icons.trending_up),
      selectedIcon: const Icon(Icons.trending_up_rounded),
      selectedColor: TColors.primary,
      unSelectedColor: Colors.grey,
      title: const Text('Digital Marketing'),
    ),
    BottomBarItem(
      icon: const Icon(Icons.business),
      selectedIcon: const Icon(Icons.business_center),
      selectedColor: TColors.primary,
      unSelectedColor: Colors.grey,
      title: const Text('Social'),
    ),

    BottomBarItem(
      icon: const Icon(Icons.business),
      selectedIcon: const Icon(Icons.business_center),
      selectedColor: TColors.primary,
      unSelectedColor: Colors.grey,
      title: const Text('Inbox'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var _notificationCount = 10;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            _currentTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: TColors.primary),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          // Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: TColors.primary,
                ),
                onPressed: () {
                  // Handle notification icon press

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationScreen()),
                  );
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: CustomDrawer(
        onMenuSelected: _onMenuSelected,
        currentScreen: _currentTitle,
      ),
      body: _currentScreen,
      bottomNavigationBar: StylishBottomBar(
        option: BubbleBarOptions(
          barStyle: BubbleBarStyle.horizontal,
          bubbleFillStyle: BubbleFillStyle.outlined,
          opacity: 0.3,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        iconSpace: 10.0,
        items: _navBarsItems(),
        hasNotch: true,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            _currentTitle = [
              TTexts.dashboard,
              TTexts.filesAndPdfs,
              TTexts.marketingMaterial,
              TTexts.blog,
              TTexts.inbox,
            ][index];
            _currentScreen = _buildScreens()[index];
          });
        },
      ),
    );
  }
}
