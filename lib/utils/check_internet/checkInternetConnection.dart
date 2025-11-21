import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Production-ready Internet checker.
/// Checks both connection type and actual internet reachability.
Future<bool> checkInternetConnection(BuildContext context) async {
  try {
    // Step 1: Check if the device is connected to any network
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetSnackBar(context);
      return false;
    }

    // Step 2: Ping a reliable host (Google DNS or Cloudflare)
    final result = await InternetAddress.lookup('one.one.one.one'); // Cloudflare DNS (faster)
    if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
      return true; //  Internet reachable
    } else {
      _showNoInternetSnackBar(context);
      return false;
    }
  } on SocketException catch (_) {
    _showNoInternetSnackBar(context);
    return false;
  } catch (e) {
    debugPrint("Internet check failed: $e");
    _showNoInternetSnackBar(context);
    return false;
  }
}

/// Private helper to show red snack bar message
void _showNoInternetSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("⚠️ No Internet Connection"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ),
  );
}
