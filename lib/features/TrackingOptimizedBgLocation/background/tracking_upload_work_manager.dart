import 'dart:io';

import 'package:workmanager/workmanager.dart';

import '../debug/tracking_console_logger.dart';
import '../storage/upload_queue_dao.dart';
import '../storage/upload_queue_drainer.dart';

const String trackingUploadTask = 'tracking_upload_task';
const String trackingUploadOneOffWork = 'tracking_upload_one_off_work';
const String trackingUploadPeriodicWork = 'tracking_upload_periodic_work';

@pragma('vm:entry-point')
void trackingUploadCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    trackingConsoleLog(
      'TrackingUploadWorkManager',
      'Worker callback received task=$task.',
    );
    if (task != trackingUploadTask) {
      trackingConsoleLog(
        'TrackingUploadWorkManager',
        'Unknown task ignored successfully.',
      );
      return true;
    }

    try {
      final drainer = UploadQueueDrainer(UploadQueueDao());
      final result = await drainer.drainAvailable(maxBatches: 8);
      trackingConsoleLog(
        'TrackingUploadWorkManager',
        'Worker finished: hadWork=${result.hadWork}, '
            'processed=${result.processedCount}, retry=${result.shouldRetry}, '
            'busy=${result.busy}.',
      );
      return !result.shouldRetry;
    } catch (error, stackTrace) {
      trackingConsoleError(
        'TrackingUploadWorkManager',
        'WorkManager upload failed.',
        error,
        stackTrace,
      );
      return false;
    }
  });
}

class TrackingUploadWorkManager {
  TrackingUploadWorkManager._();

  static final TrackingUploadWorkManager instance =
      TrackingUploadWorkManager._();

  bool _initialized = false;
  DateTime? _lastOneOffRegistration;

  Future<void> initialize() async {
    if (!Platform.isAndroid || _initialized) {
      return;
    }

    await Workmanager().initialize(
      trackingUploadCallbackDispatcher,
      isInDebugMode: false,
    );
    _initialized = true;
    trackingConsoleLog('TrackingUploadWorkManager', 'Initialized.');
  }

  Future<void> registerPeriodicFallback() async {
    if (!Platform.isAndroid) {
      return;
    }

    await Workmanager().registerPeriodicTask(
      trackingUploadPeriodicWork,
      trackingUploadTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(seconds: 30),
    );
    trackingConsoleLog(
      'TrackingUploadWorkManager',
      '15-minute periodic network upload registered.',
    );
  }

  Future<void> scheduleOneOffUpload() async {
    if (!Platform.isAndroid) {
      return;
    }

    final now = DateTime.now();
    final lastRegistration = _lastOneOffRegistration;
    if (lastRegistration != null &&
        now.difference(lastRegistration) < const Duration(minutes: 2)) {
      trackingConsoleLog(
        'TrackingUploadWorkManager',
        'One-off registration skipped by the 2-minute throttle.',
      );
      return;
    }

    try {
      await Workmanager().registerOneOffTask(
        trackingUploadOneOffWork,
        trackingUploadTask,
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );
      _lastOneOffRegistration = now;
      trackingConsoleLog(
        'TrackingUploadWorkManager',
        'One-off network upload registered.',
      );
    } catch (error, stackTrace) {
      trackingConsoleError(
        'TrackingUploadWorkManager',
        'Could not schedule one-off upload.',
        error,
        stackTrace,
      );
    }
  }
}
