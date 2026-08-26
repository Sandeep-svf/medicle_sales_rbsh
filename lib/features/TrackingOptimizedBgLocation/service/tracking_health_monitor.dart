import '../storage/app_state_dao.dart';

class TrackingHealthMonitor {
  static const String heartbeatKey = 'tracking_service_heartbeat_utc';
  static const String startedAtKey = 'tracking_service_started_utc';

  final AppStateDao _appStateDao;

  TrackingHealthMonitor({AppStateDao? appStateDao})
      : _appStateDao = appStateDao ?? AppStateDao();

  Future<void> recordServiceStarted() async {
    final nowUtc = DateTime.now().toUtc().toIso8601String();
    await _appStateDao.set(startedAtKey, nowUtc);
    await _appStateDao.set(heartbeatKey, nowUtc);
  }

  Future<void> recordHeartbeat() async {
    await _appStateDao.set(
      heartbeatKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<DateTime?> lastHeartbeat() async {
    final value = await _appStateDao.get(heartbeatKey);
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }

  Future<bool> hasFreshHeartbeat({
    Duration maximumAge = const Duration(minutes: 3),
  }) async {
    final heartbeat = await lastHeartbeat();
    if (heartbeat == null) {
      return false;
    }

    return DateTime.now().toUtc().difference(heartbeat) <= maximumAge;
  }
}
