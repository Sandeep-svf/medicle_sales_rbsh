import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../features/addDoctor/services/DoctorService.dart';

//  Define this globally (top-level)
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;
  NetworkMonitor._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOfflineShown = false;

  void startMonitoring(BuildContext context) {
    print('[NetworkMonitor]  Started monitoring connectivity...');
    _subscription?.cancel();

    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      print('[NetworkMonitor]  Connectivity changed: $result');

      if (result == ConnectivityResult.none) {
        _isOfflineShown = true;
        _showSnackBar("️ No Internet Connection");
        return;
      }

      try {
        final lookup = await InternetAddress.lookup('one.one.one.one');
        if (lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty) {
          if (_isOfflineShown) {
            _isOfflineShown = false;
            _showSnackBar(" Back Online");
            await DoctorService().syncOfflineDoctors();
          }
        }
      } on SocketException {
        _showSnackBar(" Internet Unreachable");
      }
    });
  }

  void stopMonitoring() {
    print('[NetworkMonitor]  Stopping monitoring.');
    _subscription?.cancel();
    _subscription = null;
  }

  void _showSnackBar(String message) {
    print('[NetworkMonitor] Snackbar → $message');

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      print('[NetworkMonitor]  No ScaffoldMessenger available yet');
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.center),
          backgroundColor:
          message.contains("Back") ? Colors.green : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
