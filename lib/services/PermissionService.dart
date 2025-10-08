import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Ask for location + notifications (A13+) cleanly.
  static Future<bool> requestAll() async {
    // Order matters: Fine -> Background -> Notifications.
    final loc = await Permission.location.request();
    if (!loc.isGranted) return false;

    // Some OEMs require a small delay before BG request.
    final bg = await Permission.locationAlways.request();
    if (!bg.isGranted) return false;

    // Android 13+ notifications for foreground service notification visibility.
    final notif = await Permission.notification.request();
    return notif.isGranted || notif.isLimited || notif.isProvisional;
  }

  static Future<bool> hasAll() async {
    final fine = await Permission.location.status;
    final bg = await Permission.locationAlways.status;
    final notif = await Permission.notification.status;
    return fine.isGranted && bg.isGranted && (notif.isGranted || notif.isLimited || notif.isProvisional);
  }

  /// Optional: navigate user to settings if permanently denied.
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
