import 'dart:async';
import 'dart:io';

import 'package:medicle_sales_rbsh/utils/http/api_http.dart' as http;

import '../constants/text_strings.dart';

/// User-facing API errors. Never surface transport exceptions or request URLs.
class ApiUiFeedback {
  const ApiUiFeedback._();

  static String message(Object error) {
    if (error is SocketException ||
        error is http.ClientException ||
        error is TimeoutException) {
      return TTexts.networkUnavailable;
    }

    final description = error.toString().toLowerCase();
    if (description.contains('socketexception') ||
        description.contains('failed host lookup') ||
        description.contains('network is unreachable') ||
        description.contains('connection refused') ||
        description.contains('connection reset') ||
        description.contains('connection closed') ||
        description.contains('no internet') ||
        description.contains('connection error') ||
        description.contains('timed out')) {
      return TTexts.networkUnavailable;
    }
    return TTexts.requestFailed;
  }
}
