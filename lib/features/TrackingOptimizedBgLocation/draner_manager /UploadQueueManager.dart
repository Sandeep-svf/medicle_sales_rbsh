import 'dart:async';

import '../storage/upload_queue_dao.dart';
import '../storage/upload_queue_drainer.dart';

class UploadQueueManager {
  static final UploadQueueManager instance = UploadQueueManager._();

  UploadQueueManager._();

  Timer? _timer;

  Future<void> start() async {
    final dao = UploadQueueDao();
    final drainer = UploadQueueDrainer(dao);

    _timer ??= Timer.periodic(
      const Duration(seconds: 10),
          (_) async {
        await drainer.drainOnce();
      },
    );
  }
}