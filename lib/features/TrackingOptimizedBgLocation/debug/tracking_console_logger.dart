import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

void trackingConsoleLog(String source, String message) {
  if (kDebugMode) {
    debugPrint('[$source] $message');
  }
}

void trackingConsoleError(
  String source,
  String message,
  Object error,
  StackTrace stackTrace,
) {
  developer.log(
    message,
    name: source,
    error: error,
    stackTrace: stackTrace,
  );

  if (kDebugMode) {
    debugPrint('[$source] ERROR: $message — $error');
    debugPrintStack(
      label: '[$source] Stack trace',
      stackTrace: stackTrace,
    );
  }
}

String trackingConsolePreview(String value, {int maxLength = 800}) {
  final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= maxLength) {
    return normalized;
  }

  return '${normalized.substring(0, maxLength)}…';
}
