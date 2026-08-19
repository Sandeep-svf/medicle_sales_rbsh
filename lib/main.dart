import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart' as provider;

import 'app.dart';
import 'firebase_options.dart';

import 'features/leaves/controller/LeaveController.dart';
import 'features/salesActivity/controllers/SalesController.dart';

import 'utils/notificationservice/PushNotificationService.dart';

// ============================================================
// TRACKING
// ============================================================

import 'features/TrackingOptimizedBgLocation/service/tracking_service_manager.dart';
import 'features/TrackingOptimizedBgLocation/storage/app_state_dao.dart';
import 'features/TrackingOptimizedBgLocation/utils/device_info_plus.dart';


// ============================================================
// FIREBASE BACKGROUND MESSAGE
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    '[FCM] Background message: ${message.messageId}',
  );
}


// ============================================================
// FIREBASE IN-APP MESSAGING
// ============================================================

void initFIAM() {
  FirebaseInAppMessaging.instance
      .setMessagesSuppressed(false);
}


// ============================================================
// DEVICE ID
//
// IMPORTANT:
//
// getAndroidId() uses your native MethodChannel('device_id').
//
// We call it from the MAIN Flutter engine and store it inside
// app_state.
//
// Background service must NOT call that MethodChannel.
// It will read app_state.device_id instead.
// ============================================================

Future<void> ensureTrackingDeviceId() async {
  try {
    final appStateDao = AppStateDao();

    // --------------------------------------------------------
    // STEP 1
    // Check if device ID was already stored previously.
    //
    // Existing Play Store users will reuse it.
    // --------------------------------------------------------

    final existingDeviceId =
    await appStateDao.get('device_id');

    if (existingDeviceId != null &&
        existingDeviceId.trim().isNotEmpty) {
      debugPrint(
        '[DEVICE_ID] Existing ID found: $existingDeviceId',
      );

      return;
    }

    // --------------------------------------------------------
    // STEP 2
    // Get ANDROID_ID through the MAIN Flutter engine.
    // --------------------------------------------------------

    debugPrint(
      '[DEVICE_ID] No saved ID. Reading Android ID...',
    );

    final deviceId = await getAndroidId();

    // --------------------------------------------------------
    // STEP 3
    // Safety check.
    // --------------------------------------------------------

    if (deviceId.trim().isEmpty) {
      debugPrint(
        '[DEVICE_ID] ERROR: Android ID returned empty.',
      );

      // Do not create/save an empty device ID.
      //
      // Tracking can still store data locally.
      // Background uploader should skip server upload until
      // a valid device ID exists.
      return;
    }

    // --------------------------------------------------------
    // STEP 4
    // Persist Android ID.
    // --------------------------------------------------------

    await appStateDao.set(
      'device_id',
      deviceId,
    );

    debugPrint(
      '[DEVICE_ID] Android ID saved successfully: $deviceId',
    );

    // --------------------------------------------------------
    // STEP 5
    // Read back once for verification.
    // --------------------------------------------------------

    final savedDeviceId =
    await appStateDao.get('device_id');

    debugPrint(
      '[DEVICE_ID] DB verification: $savedDeviceId',
    );
  } catch (e, s) {
    debugPrint(
      '[DEVICE_ID] Initialization failed: $e',
    );

    debugPrint(
      '[DEVICE_ID] StackTrace: $s',
    );
  }
}


// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint(
    '[MAIN] ========================================',
  );
  debugPrint(
    '[MAIN] Application starting...',
  );
  debugPrint(
    '[MAIN] ========================================',
  );

  // =========================================================
  // FIREBASE
  // =========================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await FirebaseAnalytics.instance
      .setAnalyticsCollectionEnabled(true);

  initFIAM();

  // =========================================================
  // PUSH NOTIFICATION INITIALIZATION
  //
  // Permission itself is handled from Splash.
  // =========================================================

  await PushNotificationService.init();

  // =========================================================
  // EXISTING GETX CONTROLLERS
  // =========================================================

  Get.put(
    LeaveController(),
  );

  // =========================================================
  // DEVICE ID
  //
  // MUST BE BEFORE TRACKING SERVICE CONFIGURATION.
  //
  // This puts:
  //
  // app_state:
  //
  // key       = device_id
  // value     = your permanent ANDROID_ID
  //
  // Background service can now read this without MethodChannel.
  // =========================================================

  await ensureTrackingDeviceId();

  // =========================================================
  // TRACKING SERVICE
  //
  // CONFIGURE ONLY.
  //
  // Splash will call ensureRunning() after permissions.
  // =========================================================

  final trackingConfigured =
  await TrackingServiceManager
      .instance
      .configure();

  debugPrint(
    '[MAIN] Tracking service configured: '
        '$trackingConfigured',
  );

  // =========================================================
  // IMPORTANT
  //
  // DO NOT start UploadQueueManager here anymore.
  //
  // REMOVE:
  //
  // await UploadQueueManager.instance.start();
  //
  // Background location service will own the upload queue.
  // =========================================================


  // =========================================================
  // RUN APPLICATION
  // =========================================================

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (_) => SalesController(),
          ),
        ],
        child: const App(),
      ),
    ),
  );
}