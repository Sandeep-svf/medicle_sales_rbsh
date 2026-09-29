import 'package:flutter/material.dart';

import '../constants/text_strings.dart';
import '../http/api_request_loader.dart';
import 'fieldomni_loader.dart';

/// Shows the shared loader, with the existing spinner for visit confirmation.
class ApiWaitDialog {
  const ApiWaitDialog._();

  static Future<T> run<T>(
    BuildContext context, {
    required Future<T> Function() action,
    String title = TTexts.uiTextSubmitting,
    bool visitConfirmation = false,
  }) async {
    ApiRequestLoader.suppressOverlay();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: visitConfirmation
              ? const SizedBox(
                  width: 80,
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                )
              : FieldOmniLoader(
                  message: title,
                  showSurface: true,
                ),
        ),
      ),
    );
    try {
      return await action();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ApiRequestLoader.resumeOverlay();
    }
  }
}
