import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CircularLoaderController {
  static bool _isLoading = false; // Track whether the loader is running
  static BuildContext? _context;

  // Method to show the loader
  static void showLoader(BuildContext context) {
    if (_isLoading) {
      // If loader is already running, don't show a new one
      return;
    }

    _context = context; // Store the context
    _isLoading = true; // Set the loader status to running

    // Show the loading indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent closing the dialog
          child: const Dialog(
            backgroundColor: Colors.transparent,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to hide the loader
  static void hideLoader() {
    if (!_isLoading || _context == null) {
      // If loader is not running or context is null, no need to hide
      return;
    }

    _isLoading = false; // Set the loader status to stopped

    // Close the dialog (hide loader)
    Navigator.of(_context!).pop();
  }
}
