/// user_list_screen.dart
/// A simple Flutter screen that shows a list of users (dummy data)
/// with two actions per user: "Current Location" and "Show Route".
///
/// Dependencies (add to pubspec.yaml):
///   geolocator: ^12.0.0
///   url_launcher: ^6.3.0
///
/// Android (android/app/src/main/AndroidManifest.xml):
///   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
///   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
///
/// iOS (ios/Runner/Info.plist):
///   <key>NSLocationWhenInUseUsageDescription</key>
///   <string>This app uses your location to show routes.</string>

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/models/UserModel.dart';
import '../Model/UserListResponseModel.dart';
import 'GoogleMapRouteScreen.dart';


import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Controller/UserListController.dart';  // Import the correct UserListController
import 'GoogleMapRouteScreen.dart';  // Import your route screen for Google Maps

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Controller/UserListController.dart';  // Import your UserListController

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Controller/UserListController.dart';  // Import the correct controller



import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../Controller/UserListController.dart';  // Import your UserListController
import 'GoogleMapRouteScreen.dart';  // Import your route screen for Google Maps
import '../Model/UserListResponseModel.dart';  // Make sure this import is correct

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserListController userListController = Get.put(UserListController());
  Position? _lastPosition;
  bool _gettingLocation = false;

  Future<Position?> _getCurrentPosition() async {
    setState(() => _gettingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _snack('Location services are disabled. Please enable them.');
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (mounted) _snack('Location permission denied.');
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _snack('Location permission permanently denied. Enable it in Settings.');
        }
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _lastPosition = pos;
      if (mounted) {
        _snack(
          'You are at: ${pos.latitude.toStringAsFixed(5)}, '
              '${pos.longitude.toStringAsFixed(5)}',
        );
      }
      return pos;
    } catch (e) {
      if (mounted) _snack('Failed to get location: $e');
      return null;
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _openRouteTo(Usert user) async {
    final pos = _lastPosition ?? await _getCurrentPosition();
    if (pos == null) return;

    final origin = '${pos.latitude},${pos.longitude}';
    final destination = '${"user.lat"},${"user.lng"}';  // Assuming lat/lng is available in the Usert model

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&origin=$origin'
          '&destination=$destination'
          '&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack('Could not open Google Maps.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch user list when screen initializes
    userListController.fetchUserListByState("YourStateHere"); // Replace with actual state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        actions: [
          IconButton(
            tooltip: 'Get current location',
            onPressed: _gettingLocation ? null : _getCurrentPosition,
            icon: _gettingLocation
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                : const Icon(Icons.my_location),
          )
        ],
      ),
      body: Obx(() {
        if (userListController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userListController.userList.isEmpty) {
          return const Center(child: Text('No users available'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: userListController.userList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final u = userListController.userList[i]; // Getting user data from the list
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display user name
                    Text(u.name ?? 'No Name', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),

                    // Display role
                    Row(
                      children: [
                        const Icon(Icons.work_outline, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(u.role ?? 'Not Assigned')),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Display email
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(u.email ?? 'No Email')),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Display mobile number
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(u.mobileNumber ?? 'No Mobile')),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Display state
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(u.state ?? 'No State')),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Display salary amount
                    Row(
                      children: [
                        const Icon(Icons.monetization_on_outlined, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text('₹${u.salaryAmount?.toString() ?? 'Not Assigned'}')),
                      ],
                    ),
                    const Divider(), // Adds a line for separation
                    const SizedBox(height: 12),

                    // Buttons for interactive actions
                    Row(
                      children: [
                        // Current Location Button
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _gettingLocation ? null : _getCurrentPosition,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Current Location'),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Show Route Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // First, perform the logic to open the route (your existing method)
                             // _openRouteTo(u);

                              // Then, navigate to the RouteMapScreen and pass user data
                              Get.to(() => RouteMapScreen(), arguments: u.id);  // Passing user name
                            },
                            icon: const Icon(Icons.route),
                            label: const Text('Show Route'),
                          ),
                        )

                      ],
                    ),
                    const SizedBox(height: 10),

                    // Show Details Button (To open a detailed dialog or page)
                    Center(
                      child: TextButton(
                        onPressed: () => _showUserDetailsDialog(context, u),
                        child: const Text(
                          'Show Details',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Function to show a detailed dialog with user info
  void _showUserDetailsDialog(BuildContext context, Usert u) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10, // Adds shadow for better visibility
          backgroundColor: Colors.white, // Background color of the dialog
          title: Text(
            u.name ?? 'User Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserDetailRow(Icons.badge, 'Employee Code', u.employeeCode),
                _buildUserDetailRow(Icons.business, 'Department', u.department),
                _buildUserDetailRow(Icons.home_work, 'Head Office', u.headOffice),
                _buildUserDetailRow(Icons.account_balance, 'Branch', u.branch),
                _buildUserDetailRow(Icons.work, 'Employment Type', u.employmentType),
                _buildUserDetailRow(
                    Icons.check_circle_outline,
                    'Active',
                    u.isActive == true ? 'Yes' : 'No'
                ),
                _buildUserDetailRow(Icons.access_time, 'Created At', u.createdAt),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with background for better visibility
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? 'Not Available',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }



}




/*
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _users = <AppUser>[
    AppUser(
      name: 'Aarav Sharma',
      email: 'aarav@example.com',
      address: 'Terminal 3, IGI Airport, New Delhi',
      lat: 28.5562,
      lng: 77.1000,
    ),
    AppUser(
      name: 'Priya Nair',
      email: 'priya@example.com',
      address: 'Marine Drive, Mumbai',
      lat: 18.9430,
      lng: 72.8238,
    ),
    AppUser(
      name: 'Rahul Verma',
      email: 'rahul@example.com',
      address: 'Charminar, Hyderabad',
      lat: 17.3616,
      lng: 78.4747,
    ),
    AppUser(
      name: 'Aarav Sharma',
      email: 'aarav@example.com',
      address: 'Terminal 3, IGI Airport, New Delhi',
      lat: 28.5562,
      lng: 77.1000,
    ),
    AppUser(
      name: 'Priya Nair',
      email: 'priya@example.com',
      address: 'Marine Drive, Mumbai',
      lat: 18.9430,
      lng: 72.8238,
    ),
    AppUser(
      name: 'Rahul Verma',
      email: 'rahul@example.com',
      address: 'Charminar, Hyderabad',
      lat: 17.3616,
      lng: 78.4747,
    ),
    AppUser(
      name: 'Aarav Sharma',
      email: 'aarav@example.com',
      address: 'Terminal 3, IGI Airport, New Delhi',
      lat: 28.5562,
      lng: 77.1000,
    ),
    AppUser(
      name: 'Priya Nair',
      email: 'priya@example.com',
      address: 'Marine Drive, Mumbai',
      lat: 18.9430,
      lng: 72.8238,
    ),
    AppUser(
      name: 'Rahul Verma',
      email: 'rahul@example.com',
      address: 'Charminar, Hyderabad',
      lat: 17.3616,
      lng: 78.4747,
    ),
  ];

  Position? _lastPosition;
  bool _gettingLocation = false;

  Future<Position?> _getCurrentPosition() async {
    setState(() => _gettingLocation = true);
    try {
      // Ensure service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _snack('Location services are disabled. Please enable them.');
        }
        return null;
      }

      // Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (mounted) _snack('Location permission denied.');
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _snack('Location permission permanently denied. Enable it in Settings.');
        }
        return null;
      }

      // Get current position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastPosition = pos;
      if (mounted) {
        _snack(
          'You are at: ${pos.latitude.toStringAsFixed(5)}, '
              '${pos.longitude.toStringAsFixed(5)}',
        );
      }
      return pos;
    } catch (e) {
      if (mounted) _snack('Failed to get location: $e');
      return null;
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _openRouteTo(AppUser user) async {
    // Use cached position if available; otherwise fetch
    final pos = _lastPosition ?? await _getCurrentPosition();
    if (pos == null) return;

    final origin = '${pos.latitude},${pos.longitude}';
    final destination = '${user.lat},${user.lng}';

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&origin=$origin'
          '&destination=$destination'
          '&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack('Could not open Google Maps.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Get current location',
            onPressed: _gettingLocation ? null : _getCurrentPosition,
            icon: _gettingLocation
                ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator())
                : const Icon(Icons.my_location),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final u = _users[i];
          return Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(u.email)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(u.address)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                          _gettingLocation ? null : _getCurrentPosition,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Current Location'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RouteMapScreen(), // your screen
                              ),
                            );
                          },
                          icon: const Icon(Icons.route),
                          label: const Text('Show Route'),
                        ),
                      )

                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppUser {
  final String name;
  final String email;
  final String address;
  final double lat;
  final double lng;

  const AppUser({
    required this.name,
    required this.email,
    required this.address,
    required this.lat,
    required this.lng,
  });
}*/
