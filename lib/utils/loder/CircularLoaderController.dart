import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/http/api_request_loader.dart';

import 'fieldomni_loader.dart';

class CircularLoaderController {
  static bool _isLoading = false;
  static BuildContext? _context;

  static void showLoader(BuildContext context) {
    if (_isLoading) return;

    _context = context;
    _isLoading = true;
    ApiRequestLoader.suppressOverlay();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: TColors.transparent,
          child: FieldOmniLoader(
            message: 'Please wait...',
            showSurface: true,
          ),
        ),
      ),
    ).catchError((Object _) {
      _isLoading = false;
      _context = null;
      ApiRequestLoader.resumeOverlay();
    });
  }

  static void hideLoader() {
    if (!_isLoading || _context == null) return;

    _isLoading = false;
    final context = _context!;
    _context = null;
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    ApiRequestLoader.resumeOverlay();
  }
}
