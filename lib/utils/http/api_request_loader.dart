import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';

import '../loder/fieldomni_loader.dart';
import 'api_request_visibility.dart';

/// Keeps API activity visible through one shared FieldOmni loading overlay.
class ApiRequestLoader {
  ApiRequestLoader._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static int _pendingRequests = 0;
  static Timer? _showTimer;
  static OverlayEntry? _entry;
  static final _dioInterceptors = Expando<bool>('FieldOmniLoaderAttached');

  static Future<T> track<T>(Future<T> Function() request) async {
    begin();
    try {
      return await request();
    } finally {
      complete();
    }
  }

  static void begin() {
    _pendingRequests++;
    ApiRequestVisibility.listen(_onVisibilityChanged);
    _scheduleOverlay();
  }

  static void complete() {
    if (_pendingRequests == 0) return;
    _pendingRequests--;
    if (_pendingRequests != 0) return;

    _showTimer?.cancel();
    _showTimer = null;
    final entry = _entry;
    _entry = null;
    if (entry != null) {
      entry.remove();
      entry.dispose();
    }
  }

  /// Adds request and response hooks to a Dio instance once.
  static dio.Dio trackDio(dio.Dio client) {
    if (_dioInterceptors[client] == true) return client;
    _dioInterceptors[client] = true;
    client.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          begin();
          handler.next(options);
        },
        onResponse: (response, handler) {
          complete();
          handler.next(response);
        },
        onError: (error, handler) {
          complete();
          handler.next(error);
        },
      ),
    );
    return client;
  }

  /// Hides the request overlay while another FieldOmni loading dialog is shown.
  static void suppressOverlay() {
    ApiRequestVisibility.suppress();
  }

  static void resumeOverlay() {
    ApiRequestVisibility.resume();
  }

  static void _show() {
    _showTimer = null;
    if (_pendingRequests == 0 ||
        ApiRequestVisibility.isSuppressed ||
        _entry != null) {
      return;
    }
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xFF00384F).withValues(alpha: 0.08),
              ),
            ),
            const FieldOmniLoader(
              message: 'Please wait...',
              showSurface: true,
              suppressApiActivityLoader: false,
            ),
          ],
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void _scheduleOverlay() {
    if (_pendingRequests == 0 ||
        ApiRequestVisibility.isSuppressed ||
        _entry != null ||
        _showTimer != null) {
      return;
    }
    _showTimer = Timer(const Duration(milliseconds: 180), _show);
  }

  static void _onVisibilityChanged() {
    if (ApiRequestVisibility.isSuppressed) {
      _showTimer?.cancel();
      _showTimer = null;
      final entry = _entry;
      _entry = null;
      if (entry != null) {
        entry.remove();
        entry.dispose();
      }
    } else {
      _scheduleOverlay();
    }
  }
}
