import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  // Request location permission
  static Future<bool> requestLocationPermission() async {
    var permission = await Permission.location.request();

    if (permission.isDenied || permission.isPermanentlyDenied) {
      return false;
    }
    return true;
  }
}
