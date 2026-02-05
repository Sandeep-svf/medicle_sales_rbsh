import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medicle_sales_rbsh/features/addDoctor/screens/add_doctro_new_screen.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/screens/ScheduleVisit.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/screens/ScheduleVisitScreen.dart';

import '../../../utils/http/http_client.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/Screen/salesChartHome.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../../Blog/screen/blog.dart';
import '../../Inbox/Screen/InboxScreen.dart';
import '../../MarketingMaterials/Screens/MarketingMaterials.dart';
import '../../SalesChartAnalysis/Screen/salesChartHome2.dart';
import '../../addDoctor/screens/addDoctor.dart';
import '../../marketing/screen/MarketingScreen.dart';
import '../../marketing/screen/marketing.dart';
import '../../notification/screen/NotificatinScreen.dart';
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
  String? userRole;
  late final  userData;

  String? currentVersion;
  String? playStoreVersion="0.0.0";
  Map<String, String>? deviceInfo;

  @override
  void initState() {
    super.initState();
    fetchVersionInfo(); // Call the function to fetch version details
    fetchUserRole();
    _navigateToSalesChartHome();
    updateFCMToken();
  }

  Future<void> updateFCMToken() async {

    AuthManager authManager = AuthManager();
    final token = await authManager.getAuthToken();

    const baseUrl = THttpHelper.baseUrl;
    final fcmToken = await getFCMToken();

    final url = Uri.parse('$baseUrl/users/fcm-token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCM Token synced successfully.');
      } else {
        // Handle server-side errors
        print('Failed to update token. Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error occurred while updating FCM token: $e');
      rethrow;
    }
  }




  Future<String?> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      // 1. Request permission (Required for iOS and Android 13+)
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Fetch the token
        String? token = await messaging.getToken();

        print('FCM Token Generated ---');
        print('FCM $token');
        return token;
      } else {
        print('User declined or has not accepted permission');
        return null;
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
      return null;
    }
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  // Function to fetch user role from SharedPreferences
  Future<void> fetchUserRole() async {
    AuthManager authManager = AuthManager();
    String? role = await authManager.getUserRole();  // Fetch the user role
    setState(() {
      userRole = role;  // Update the user role state
    });


  }



  // Function to navigate to SalesChartHomeScreen
  void _navigateToSalesChartHome() {
    setState(() {
      _currentTitle = TTexts.dashboard;
      _currentScreen = SalesChartHomeScreen();
    });
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
    ScheduleVisit(),
    AddDoctorScreen(),
    InboxScreen()
  ];

  // working fine.

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
      icon: const Icon(Icons.schedule_outlined),
      selectedIcon: const Icon(Icons.schedule_sharp),
      selectedColor: TColors.primary,
      unSelectedColor: Colors.grey,
      title: const Text('Appointments'),
    ),
    BottomBarItem(
      icon: const Icon(Icons.medical_services_outlined),
      selectedIcon: const Icon(Icons.medical_services_outlined),
      selectedColor: TColors.primary,
      unSelectedColor: Colors.grey,
      title: const Text('Add Doctor'),
    ),

    BottomBarItem(
      icon: const Icon(Icons.inbox_outlined),
      selectedIcon: const Icon(Icons.all_inbox),
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
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
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
                  color: Colors.white,
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
        userRole: userRole ?? '',  // Pass userRole to CustomDrawer
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
              TTexts.appointments,
              TTexts.addDoctor,
              TTexts.inbox,
            ][index];
            _currentScreen = _buildScreens()[index];
          });
        },
      ),
    );
  }



  Future<void> fetchPlayStoreVersion() async {
    try {
      // Get current installed app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;  // e.g., 1.2.3
      int currentVersionCode = int.parse(packageInfo.buildNumber); // e.g., 12

      // Check if update is available (without triggering update)
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        int playStoreVersionCode = updateInfo.availableVersionCode!;
        playStoreVersion = playStoreVersion.toString();
        print("[DEBUG] Installed version code: $currentVersionCode");
        print("[DEBUG] Play Store version code: $playStoreVersionCode");

        if (playStoreVersionCode > currentVersionCode) {
          print("[DEBUG] Update available on Play Store!");
        } else {
          print("[DEBUG] App is up-to-date.");
        }
      } else {
        print("[DEBUG] App is up-to-date. No update available on Play Store.");
      }
    } catch (e) {
      print("Error fetching Play Store version: $e");
    }
  }


  // Function to fetch version information from the server
  Future<void> fetchVersionInfo() async {
    try {

     // await fetchPlayStoreVersion();
      // Fetch the current app version using `package_info_plus`
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
     // AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
     // int playStoreVersionCode = updateInfo.availableVersionCode!;
      setState(() {
        currentVersion = packageInfo.version;  // Current app version (e.g., 1.2.3)

       // playStoreVersion = playStoreVersionCode.toString();  // This could be fetched dynamically or hardcoded
      });

      // Fetch device info using `device_info_plus`
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      setState(() {
        deviceInfo = {
          'deviceId': androidInfo.id ?? 'Unknown ID',  // Android device ID
          'platform': "android",  // Platform
          'osVersion': androidInfo.version.release ?? 'Unknown Version',  // OS version (e.g., 11.0)
        };
      });

      print("[DEBUG] Device Info: $deviceInfo");
      print("[DEBUG] App Info: $currentVersion, $playStoreVersion");

      // Sending version and device info to the server
      AuthManager authManager = AuthManager();
      final token = await authManager.getAuthToken();  // Get the token



      final response = await http.post(
        Uri.parse('${THttpHelper.baseUrl}/version/check'),
        headers: {
          "Authorization": "Bearer $token",  // Add Bearer token
          "Accept": "application/json",  // Ensure server expects JSON
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "currentVersion": currentVersion,
          "deviceInfo": deviceInfo,
          "buildNumber": "1024"
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("[DEBUG] Server Response: $jsonResponse");
      } else {
        print("[DEBUG] Failed to send version info. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("[DEBUG] Error fetching version info: $e");
    }
  }

}
