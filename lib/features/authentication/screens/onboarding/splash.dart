import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:in_app_update/in_app_update.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/local_storage/auth_manager.dart';

import '../../../TrackingOptimizedBgLocation/service/tracking_service_manager.dart';
import '../../../TrackingOptimizedBgLocation/service/tracking_health_monitor.dart';
import '../../../TrackingOptimizedBgLocation/storage/app_state_dao.dart';
import '../../../TrackingOptimizedBgLocation/utils/samsung_battery_settings.dart';
import '../../../dashboard/screen/dashboard.dart';

import '../login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  bool _startupRunning = false;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    // Listen to foreground Firebase notifications.
    _foregroundMessageSubscription =
        FirebaseMessaging.onMessage.listen(
              (RemoteMessage message) {
            final notification = message.notification;

            if (notification != null) {
              _showPushNotification(
                title: notification.title ?? 'New Message',
                body: notification.body ?? '',
              );
            }
          },
        );

    // IMPORTANT:
    // Permission dialogs should only start after first frame.
    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _startFlow();
      },
    );
  }

  // =========================================================
  // MAIN STARTUP FLOW
  // =========================================================

  Future<void> _startFlow() async {
    if (_startupRunning) {
      return;
    }

    _startupRunning = true;

    try {
      debugPrint(
        '[SPLASH] ========================================',
      );
      debugPrint(
        '[SPLASH] Starting application startup flow',
      );
      debugPrint(
        '[SPLASH] ========================================',
      );

      // -----------------------------------------------------
      // STEP 1: TRACKING PERMISSIONS
      // -----------------------------------------------------

      final trackingReady = await _prepareTracking();

      if (!trackingReady) {
        debugPrint(
          '[SPLASH] Tracking prerequisites not ready.',
        );

        _startupRunning = false;
        return;
      }

      // -----------------------------------------------------
      // STEP 2: NORMAL ANDROID BATTERY OPTIMIZATION
      // -----------------------------------------------------

      await _handleBatteryOptimization();

      // -----------------------------------------------------
      // STEP 3: CHECK SAMSUNG TRACKING HEALTH
      // -----------------------------------------------------

      final samsungSetupRequired =
      await _isSamsungBackgroundSetupRequired();

      // -----------------------------------------------------
      // STEP 4: START / VERIFY TRACKING SERVICE
      // -----------------------------------------------------

      final serviceReady =
      await _ensureTrackingServiceRunning();

      if (!serviceReady) {
        debugPrint(
          '[SPLASH] Tracking service could not start.',
        );

        _startupRunning = false;
        return;
      }

      debugPrint(
        '[SPLASH] Tracking service is running.',
      );

      if (samsungSetupRequired) {
        await _handleSamsungBackgroundUsageSetup(
          forceReview: true,
        );

        final serviceStillReady =
        await _ensureTrackingServiceRunning();

        if (!serviceStillReady) {
          _startupRunning = false;
          return;
        }
      }

      // -----------------------------------------------------
      // STEP 5: PLAY STORE UPDATE CHECK
      // -----------------------------------------------------

      await _checkForUpdateAndNavigate();
    } catch (e, s) {
      debugPrint(
        '[SPLASH] Startup error: $e',
      );

      debugPrint(
        '[SPLASH] StackTrace: $s',
      );

      _startupRunning = false;

      if (mounted) {
        await _showStartupErrorDialog();
      }
    }
  }



  // =========================================================
// SAMSUNG BACKGROUND USAGE LIMITS
//
// Samsung only.
//
// We cannot silently modify Samsung's Sleeping / Deep
// Sleeping / Never Sleeping lists.
//
// Therefore we guide the user/admin through all 3 screens
// one time and save completion in app_state.
// =========================================================

  Future<bool> _isSamsungBackgroundSetupRequired() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final isSamsung =
      await SamsungBatterySettings.isSamsungDevice();
      if (!isSamsung) {
        return false;
      }

      final appStateDao = AppStateDao();
      final setupDone = await appStateDao.get(
        'samsung_background_setup_done',
      );

      if (setupDone != 'true') {
        return true;
      }

      final healthy = await TrackingHealthMonitor(
        appStateDao: appStateDao,
      ).hasFreshHeartbeat();

      if (!healthy) {
        debugPrint(
          '[SAMSUNG_BATTERY] Tracking heartbeat is stale. '
              'Samsung setup will be reviewed.',
        );
      }

      return !healthy;
    } catch (e, s) {
      debugPrint(
        '[SAMSUNG_BATTERY] Health check error: $e',
      );
      debugPrint('$s');
      return false;
    }
  }

  Future<void> _handleSamsungBackgroundUsageSetup({
    bool forceReview = false,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      // -----------------------------------------------------
      // CHECK SAMSUNG
      // -----------------------------------------------------

      final isSamsung =
      await SamsungBatterySettings.isSamsungDevice();

      debugPrint(
        '[SAMSUNG_BATTERY] Samsung device: $isSamsung',
      );

      if (!isSamsung) {
        debugPrint(
          '[SAMSUNG_BATTERY] Not Samsung. Skipping.',
        );

        return;
      }

      // -----------------------------------------------------
      // CHECK ONE-TIME SETUP FLAG
      // -----------------------------------------------------

      final appStateDao = AppStateDao();

      final setupDone =
      await appStateDao.get(
        'samsung_background_setup_done',
      );

      debugPrint(
        '[SAMSUNG_BATTERY] '
            'Saved setup status: $setupDone',
      );

      if (setupDone == 'true' && !forceReview) {
        debugPrint(
          '[SAMSUNG_BATTERY] '
              'Samsung background setup already completed.',
        );

        return;
      }

      if (!mounted) {
        return;
      }

      // -----------------------------------------------------
      // INTRODUCTION
      // -----------------------------------------------------

      await _showSamsungBackgroundIntro();

      if (!mounted) {
        return;
      }

      // -----------------------------------------------------
      // STEP 1: SLEEPING APPS
      // -----------------------------------------------------

      await _showSamsungSleepingInstruction();

      if (!mounted) {
        return;
      }

      debugPrint(
        '[SAMSUNG_BATTERY] Opening Sleeping apps...',
      );

      await SamsungBatterySettings.openSleepingApps();

      await _waitForSettingsRoundTrip();

      if (!mounted) {
        return;
      }

      // -----------------------------------------------------
      // STEP 2: DEEP SLEEPING APPS
      // -----------------------------------------------------

      await _showSamsungDeepSleepingInstruction();

      if (!mounted) {
        return;
      }

      debugPrint(
        '[SAMSUNG_BATTERY] '
            'Opening Deep sleeping apps...',
      );

      await SamsungBatterySettings.openDeepSleepingApps();

      await _waitForSettingsRoundTrip();

      if (!mounted) {
        return;
      }

      // -----------------------------------------------------
      // STEP 3: NEVER AUTO SLEEPING APPS
      // -----------------------------------------------------

      await _showSamsungNeverSleepingInstruction();

      if (!mounted) {
        return;
      }

      debugPrint(
        '[SAMSUNG_BATTERY] '
            'Opening Never sleeping apps...',
      );

      await SamsungBatterySettings.openNeverSleepingApps();

      await _waitForSettingsRoundTrip();

      if (!mounted) {
        return;
      }

      // -----------------------------------------------------
      // FINAL USER CONFIRMATION
      // -----------------------------------------------------

      final confirmed =
      await _showSamsungSetupConfirmation();

      if (!confirmed) {
        debugPrint(
          '[SAMSUNG_BATTERY] '
              'Setup not confirmed. Rechecking.',
        );

        // Do not save completion.
        //
        // Restart Samsung setup immediately.
        await _handleSamsungBackgroundUsageSetup(
          forceReview: true,
        );

        return;
      }

      // -----------------------------------------------------
      // SAVE COMPLETION
      // -----------------------------------------------------

      await appStateDao.set(
        'samsung_background_setup_done',
        'true',
      );
      await appStateDao.set(
        'samsung_background_setup_checked_at_utc',
        DateTime.now().toUtc().toIso8601String(),
      );

      debugPrint(
        '[SAMSUNG_BATTERY] '
            'Samsung background setup completed.',
      );
    } catch (e, s) {
      debugPrint(
        '[SAMSUNG_BATTERY] Setup error: $e',
      );

      debugPrint(
        '[SAMSUNG_BATTERY] StackTrace: $s',
      );

      // IMPORTANT:
      //
      // Do not crash Splash because Samsung changed an OEM
      // screen on a particular One UI version.
      //
      // Normal Android battery optimization +
      // foreground tracking service still remain configured.
    }
  }



  Future<void> _waitForSettingsRoundTrip() async {
    if (!mounted) {
      return;
    }

    // Give Android a moment to launch Device Care.
    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    bool appLeftForeground = false;

    // -------------------------------------------------------
    // First wait briefly for Flutter to leave resumed state.
    //
    // If Samsung's settings Intent fails to open entirely,
    // this prevents us from waiting forever.
    // -------------------------------------------------------

    for (int i = 0; i < 20; i++) {
      if (!mounted) {
        return;
      }

      final state =
          WidgetsBinding.instance.lifecycleState;

      if (state != AppLifecycleState.resumed) {
        appLeftForeground = true;

        debugPrint(
          '[SAMSUNG_BATTERY] '
              'App moved to background/settings.',
        );

        break;
      }

      await Future.delayed(
        const Duration(milliseconds: 100),
      );
    }

    // Samsung screen did not actually move app to background.
    if (!appLeftForeground) {
      debugPrint(
        '[SAMSUNG_BATTERY] '
            'Settings lifecycle transition not detected.',
      );

      return;
    }

    // -------------------------------------------------------
    // Wait until user comes back to Gluckscare.
    // -------------------------------------------------------

    while (mounted) {
      final state =
          WidgetsBinding.instance.lifecycleState;

      if (state == AppLifecycleState.resumed) {
        debugPrint(
          '[SAMSUNG_BATTERY] '
              'Returned from Samsung settings.',
        );

        // Let Android/Flutter settle.
        await Future.delayed(
          const Duration(milliseconds: 400),
        );

        return;
      }

      await Future.delayed(
        const Duration(milliseconds: 200),
      );
    }
  }


  Future<void> _showSamsungBackgroundIntro() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Samsung Background Tracking',
            ),
            content: const Text(
              'Samsung can automatically restrict apps '
                  'that run for long periods in the background.\n\n'
                  'Gluckscare requires continuous background '
                  'location tracking for sales activity.\n\n'
                  'We will check three Samsung background '
                  'usage settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Continue',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSamsungSleepingInstruction() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Step 1 of 3',
            ),
            content: const Text(
              'Sleeping apps will open.\n\n'
                  'If Gluckscare is listed there, '
                  'REMOVE it from Sleeping apps.\n\n'
                  'Then return to Gluckscare.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Open Sleeping Apps',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void>
  _showSamsungDeepSleepingInstruction() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Step 2 of 3',
            ),
            content: const Text(
              'Deep sleeping apps will open.\n\n'
                  'Gluckscare MUST NOT be listed here.\n\n'
                  'If Gluckscare is present, REMOVE it '
                  'from Deep sleeping apps.\n\n'
                  'Then return to Gluckscare.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Open Deep Sleeping Apps',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void>
  _showSamsungNeverSleepingInstruction() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Step 3 of 3',
            ),
            content: const Text(
              'Never auto sleeping apps will open.\n\n'
                  'Tap + and ADD Gluckscare to this list.\n\n'
                  'This helps prevent Samsung from '
                  'automatically putting Gluckscare into '
                  'Sleeping or Deep sleeping mode.\n\n'
                  'After adding it, return to Gluckscare.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Open Never Sleeping Apps',
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<bool> _showSamsungSetupConfirmation() async {
    if (!mounted) {
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Confirm Background Setup',
            ),
            content: const Text(
              'Please confirm all three settings:\n\n'
                  '✓ Gluckscare is NOT in Sleeping apps.\n\n'
                  '✓ Gluckscare is NOT in Deep sleeping apps.\n\n'
                  '✓ Gluckscare IS in Never auto sleeping apps.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    false,
                  );
                },
                child: const Text(
                  'Check Again',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    true,
                  );
                },
                child: const Text(
                  'Configured',
                ),
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  // =========================================================
  // TRACKING PERMISSION FLOW
  // =========================================================

  Future<bool> _prepareTracking() async {
    // Your field deployment is Android.
    if (!Platform.isAndroid) {
      return true;
    }

    debugPrint(
      '[SPLASH] Checking tracking permissions...',
    );

    final existingForeground =
    await Permission.location.status;

    final existingBackground =
    await Permission.locationAlways.status;

    debugPrint(
      '[SPLASH] Existing foreground location: '
          '$existingForeground',
    );

    debugPrint(
      '[SPLASH] Existing background location: '
          '$existingBackground',
    );

    // -------------------------------------------------------
    // DISCLOSURE
    //
    // Existing production users that already granted both
    // permissions are NOT shown this again.
    // -------------------------------------------------------

    if (!existingForeground.isGranted ||
        !existingBackground.isGranted) {
      await _showDisclosureDialog();
    }

    // -------------------------------------------------------
    // FOREGROUND LOCATION
    // -------------------------------------------------------

    final foregroundGranted =
    await _ensureForegroundLocation();

    if (!foregroundGranted) {
      return false;
    }

    // -------------------------------------------------------
    // BACKGROUND LOCATION
    //
    // IMPORTANT:
    // Always ask AFTER foreground location.
    // -------------------------------------------------------

    final backgroundGranted =
    await _ensureBackgroundLocation();

    if (!backgroundGranted) {
      return false;
    }

    // -------------------------------------------------------
    // NOTIFICATION
    // -------------------------------------------------------

    final notificationGranted =
    await _ensureNotificationPermission();

    if (!notificationGranted) {
      return false;
    }

    // -------------------------------------------------------
    // GPS / LOCATION SERVICE
    // -------------------------------------------------------

    final locationServiceEnabled =
    await _ensureLocationServiceEnabled();

    if (!locationServiceEnabled) {
      return false;
    }

    debugPrint(
      '[SPLASH] All mandatory tracking prerequisites ready.',
    );

    return true;
  }

  // =========================================================
  // DISCLOSURE
  //
  // NO CANCEL / SKIP / NOT NOW
  // =========================================================

  Future<void> _showDisclosureDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Location Access Required',
            ),
            content: const Text(
              'Gluckscare collects location data to support '
                  'sales activity tracking, including when the app '
                  'is minimized, the screen is off, or the app is '
                  'not actively being used.\n\n'
                  'Location access is required for this application.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Continue',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // FOREGROUND LOCATION
  // =========================================================

  Future<bool> _ensureForegroundLocation() async {
    while (mounted) {
      var status =
      await Permission.location.status;

      debugPrint(
        '[SPLASH] Foreground location status: $status',
      );

      if (status.isGranted) {
        return true;
      }

      // If it is not permanently denied, request normally.
      if (!status.isPermanentlyDenied) {
        status =
        await Permission.location.request();

        debugPrint(
          '[SPLASH] Foreground location request result: '
              '$status',
        );

        if (status.isGranted) {
          return true;
        }
      }

      if (!mounted) {
        return false;
      }

      final action =
      await _showMandatoryPermissionDialog(
        title: 'Location Permission Required',
        message:
        'Gluckscare requires location access for '
            'sales tracking.\n\n'
            'Please allow location permission to continue.',
        showSettings:
        status.isPermanentlyDenied,
      );

      if (action ==
          _MandatoryPermissionAction.settings) {
        await openAppSettings();

        await Future.delayed(
          const Duration(milliseconds: 700),
        );
      }

      // Retry loops automatically.
    }

    return false;
  }

  // =========================================================
  // BACKGROUND LOCATION
  // =========================================================

  Future<bool> _ensureBackgroundLocation() async {
    while (mounted) {
      var status =
      await Permission.locationAlways.status;

      debugPrint(
        '[SPLASH] Background location status: $status',
      );

      if (status.isGranted) {
        return true;
      }

      if (!status.isPermanentlyDenied) {
        status =
        await Permission.locationAlways.request();

        debugPrint(
          '[SPLASH] Background location request result: '
              '$status',
        );

        if (status.isGranted) {
          return true;
        }
      }

      if (!mounted) {
        return false;
      }

      final action =
      await _showMandatoryPermissionDialog(
        title: 'Background Location Required',
        message:
        'Gluckscare must track sales activity while the '
            'app is minimized or the screen is off.\n\n'
            'Please open App Settings → Permissions → '
            'Location and select "Allow all the time".',
        showSettings: true,
      );

      if (action ==
          _MandatoryPermissionAction.settings) {
        await openAppSettings();

        // Allow Android time to resume this app and refresh
        // the permission state.
        await Future.delayed(
          const Duration(milliseconds: 700),
        );
      }
    }

    return false;
  }

  // =========================================================
  // NOTIFICATION PERMISSION
  // =========================================================

  Future<bool> _ensureNotificationPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    while (mounted) {
      var status =
      await Permission.notification.status;

      debugPrint(
        '[SPLASH] Notification permission status: $status',
      );

      if (status.isGranted) {
        return true;
      }

      if (!status.isPermanentlyDenied) {
        status =
        await Permission.notification.request();

        debugPrint(
          '[SPLASH] Notification request result: $status',
        );

        if (status.isGranted) {
          return true;
        }
      }

      if (!mounted) {
        return false;
      }

      final action =
      await _showMandatoryPermissionDialog(
        title: 'Notification Permission Required',
        message:
        'Notification permission is required so '
            'Gluckscare can display the active location '
            'tracking service.',
        showSettings:
        status.isPermanentlyDenied,
      );

      if (action ==
          _MandatoryPermissionAction.settings) {
        await openAppSettings();

        await Future.delayed(
          const Duration(milliseconds: 700),
        );
      }
    }

    return false;
  }

  // =========================================================
  // GPS / LOCATION SERVICE ENABLED
  // =========================================================

  Future<bool> _ensureLocationServiceEnabled() async {
    while (mounted) {
      final enabled =
      await geo.Geolocator.isLocationServiceEnabled();

      debugPrint(
        '[SPLASH] GPS/location service enabled: $enabled',
      );

      if (enabled) {
        return true;
      }

      if (!mounted) {
        return false;
      }

      await _showLocationServiceDialog();

      await geo.Geolocator.openLocationSettings();

      await Future.delayed(
        const Duration(milliseconds: 700),
      );
    }

    return false;
  }

  // =========================================================
  // MANDATORY PERMISSION DIALOG
  //
  // NO SKIP
  // NO CONTINUE WITHOUT PERMISSION
  // =========================================================

  Future<_MandatoryPermissionAction>
  _showMandatoryPermissionDialog({
    required String title,
    required String message,
    required bool showSettings,
  }) async {
    if (!mounted) {
      return _MandatoryPermissionAction.retry;
    }

    final result =
    await showDialog<_MandatoryPermissionAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    _MandatoryPermissionAction.retry,
                  );
                },
                child: const Text(
                  'Retry',
                ),
              ),

              if (showSettings)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _MandatoryPermissionAction.settings,
                    );
                  },
                  child: const Text(
                    'Open Settings',
                  ),
                ),
            ],
          ),
        );
      },
    );

    return result ??
        _MandatoryPermissionAction.retry;
  }

  // =========================================================
  // GPS DISABLED DIALOG
  // =========================================================

  Future<void> _showLocationServiceDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Location Service Required',
            ),
            content: const Text(
              'Device location/GPS must be turned on '
                  'for sales tracking to work.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Open Location Settings',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // BATTERY OPTIMIZATION
  //
  // We request this for reliability.
  //
  // IMPORTANT:
  // Unlike foreground/background location, this is NOT
  // treated as a hard Android runtime permission blocker.
  // =========================================================

  Future<bool> _handleBatteryOptimization() async {
    if (!Platform.isAndroid) {
      return true;
    }

    while (mounted) {
      try {
        // =====================================================
        // CHECK CURRENT STATUS
        // =====================================================

        final status =
        await Permission
            .ignoreBatteryOptimizations
            .status;

        debugPrint(
          '[SPLASH] Battery optimization status: $status',
        );

        // Already exempted.
        if (status.isGranted) {
          debugPrint(
            '[SPLASH] Battery optimization already disabled.',
          );

          return true;
        }

        if (!mounted) {
          return false;
        }

        // =====================================================
        // EXPLAIN WHY IT IS REQUIRED
        // =====================================================

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text(
                  'Background Tracking Required',
                ),
                content: const Text(
                  'Gluckscare needs to continue location '
                      'tracking while the screen is off or the '
                      'app is minimized.\n\n'
                      'On the next screen, please select '
                      '"Allow" to stop battery optimization '
                      'for Gluckscare.\n\n'
                      'This setting is required for reliable '
                      'background tracking.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Continue',
                    ),
                  ),
                ],
              ),
            );
          },
        );

        if (!mounted) {
          return false;
        }

        // =====================================================
        // OPEN ANDROID BATTERY EXEMPTION REQUEST
        // =====================================================

        final requestResult =
        await Permission
            .ignoreBatteryOptimizations
            .request();

        debugPrint(
          '[SPLASH] Battery optimization request result: '
              '$requestResult',
        );

        // Give Android a moment to update PowerManager state.
        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        // =====================================================
        // IMPORTANT:
        // DO NOT TRUST ONLY requestResult.
        //
        // Check the ACTUAL status again.
        // =====================================================

        final afterRequest =
        await Permission
            .ignoreBatteryOptimizations
            .status;

        debugPrint(
          '[SPLASH] Battery optimization status after request: '
              '$afterRequest',
        );

        if (afterRequest.isGranted) {
          debugPrint(
            '[SPLASH] Battery optimization exemption granted.',
          );

          return true;
        }

        // =====================================================
        // USER DENIED / CLOSED / BACKED OUT
        //
        // DO NOT CONTINUE SPLASH.
        // =====================================================

        debugPrint(
          '[SPLASH] Battery optimization was NOT granted.',
        );

        if (!mounted) {
          return false;
        }

        await _showBatteryOptimizationDeniedDialog();

        // while loop starts again:
        // status → explanation → Android request
      } catch (e, s) {
        debugPrint(
          '[SPLASH] Battery optimization error: $e',
        );

        debugPrint(
          '[SPLASH] Battery optimization stack: $s',
        );

        if (!mounted) {
          return false;
        }

        await _showBatteryOptimizationErrorDialog();

        // Retry instead of bypassing.
      }
    }

    return false;
  }

  // =========================================================
  // ENSURE TRACKING SERVICE RUNNING
  //
  // Mandatory. We do NOT navigate until service starts.
  // =========================================================

  Future<bool> _ensureTrackingServiceRunning() async {
    while (mounted) {
      try {
        final running =
        await TrackingServiceManager
            .instance
            .isRunning();

        if (running) {
          debugPrint(
            '[SPLASH] Tracking service already running.',
          );

          return true;
        }

        debugPrint(
          '[SPLASH] Starting tracking service...',
        );

        final started =
        await TrackingServiceManager
            .instance
            .ensureRunning();

        if (started) {
          debugPrint(
            '[SPLASH] Tracking service started successfully.',
          );

          return true;
        }
      } catch (e, s) {
        debugPrint(
          '[SPLASH] Tracking service start error: $e',
        );

        debugPrint('$s');
      }

      if (!mounted) {
        return false;
      }

      await _showTrackingServiceErrorDialog();
    }

    return false;
  }

  // =========================================================
  // SERVICE START ERROR
  // =========================================================

  Future<void> _showTrackingServiceErrorDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Tracking Service Required',
            ),
            content: const Text(
              'Gluckscare could not start the location '
                  'tracking service.\n\n'
                  'Please retry to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // PLAY STORE UPDATE CHECK
  // =========================================================

  Future<void> _checkForUpdateAndNavigate() async {
    try {
      debugPrint(
        '[SPLASH] Checking Play Store update...',
      );

      final info =
      await InAppUpdate.checkForUpdate();

      debugPrint(
        '[SPLASH] Update availability: '
            '${info.updateAvailability}',
      );

      if (info.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        if (!mounted) {
          return;
        }

        await _showUpdateDialog();

        return;
      }
    } catch (e) {
      // Existing behavior:
      // update-check failure must not prevent field users
      // from entering the application.
      debugPrint(
        '[SPLASH] Play Store update check error: $e',
      );
    }

    await _navigateAfterDelay();
  }

  // =========================================================
  // UPDATE DIALOG
  //
  // NO SKIP
  // =========================================================

  Future<void> _showUpdateDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              TTexts.updateAvailable,
            ),
            content: const Text(
              TTexts.updateAvailableContent,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  try {
                    debugPrint(
                      '[SPLASH] Starting immediate update...',
                    );

                    await InAppUpdate
                        .performImmediateUpdate();

                    debugPrint(
                      '[SPLASH] Immediate update completed.',
                    );
                  } catch (e) {
                    debugPrint(
                      '[SPLASH] Immediate update error: $e',
                    );
                  }

                  if (mounted) {
                    await _navigateAfterDelay();
                  }
                },
                child: const Text(
                  TTexts.updateNow,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // AUTH NAVIGATION
  //
  // IMPORTANT:
  // Tracking is already started ABOVE.
  //
  // Login state DOES NOT control tracking.
  // =========================================================

  Future<void> _navigateAfterDelay() async {
    final auth = AuthManager();

    final userId =
    await auth.getUserId();

    final token =
    await auth.getAuthToken();

    debugPrint(
      '[SPLASH] Auth userId exists: '
          '${userId != null}',
    );

    debugPrint(
      '[SPLASH] Auth token exists: '
          '${token != null}',
    );

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) {
      return;
    }

    if (userId != null &&
        token != null) {
      debugPrint(
        '[SPLASH] Navigating to Dashboard.',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(),
        ),
      );

      return;
    }

    debugPrint(
      '[SPLASH] Navigating to Login.',
    );

    // Keep your existing logout cleanup.
    //
    // IMPORTANT:
    // This does NOT stop TrackingServiceManager.
    await auth.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const LoginScreen(),
      ),
    );
  }

  // =========================================================
  // STARTUP ERROR
  // =========================================================

  Future<void> _showStartupErrorDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Unable to Start',
            ),
            content: const Text(
              'Gluckscare could not complete startup. '
                  'Please retry.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  _startupRunning = false;

                  _startFlow();
                },
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // PUSH NOTIFICATION
  // =========================================================

  void _showPushNotification({
    required String title,
    required String body,
  }) {
    final plugin =
    FlutterLocalNotificationsPlugin();

    const details =
    NotificationDetails(
      android: AndroidNotificationDetails(
        'push_channel',
        'Push Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    plugin.show(
      DateTime.now()
          .millisecondsSinceEpoch ~/
          1000,
      title,
      body,
      details,
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _foregroundMessageSubscription
        ?.cancel();

    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          TImages.lightAppLogo,
          height: 150,
        ),
      ),
    );
  }

  Future<void>
  _showBatteryOptimizationDeniedDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Permission Required',
            ),
            content: const Text(
              'Battery optimization is still enabled '
                  'for Gluckscare.\n\n'
                  'Background location tracking may stop when '
                  'the screen is off or the app is minimized.\n\n'
                  'Please allow Gluckscare to run without '
                  'battery optimization.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void>
  _showBatteryOptimizationErrorDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Battery Setting Required',
            ),
            content: const Text(
              'Gluckscare could not verify the battery '
                  'optimization setting.\n\n'
                  'Please retry to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================================
// INTERNAL PERMISSION ACTION
// ===========================================================

enum _MandatoryPermissionAction {
  retry,
  settings,
}
