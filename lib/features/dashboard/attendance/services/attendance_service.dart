
import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../model/attendance_status_model.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance = AttendanceService._();

  final AuthManager _authManager = AuthManager();

  /// Today's attendance status
  Future<AttendanceStatusModel?> getTodayStatus() async {
    try {
      final response = await THttpHelper.authGet(
        "attendance/today-status",
      );

      return AttendanceStatusModel.fromJson(response);
    } catch (e) {
      print("Attendance Status Error : $e");
      return null;
    }
  }

  /// Toggle Punch In / Punch Out
  Future<AttendanceStatusModel?> togglePunch() async {
    try {
      final userId = await _authManager.getUserId();

      final response = await THttpHelper.authPost(
        "attendance/toggle-punch",
        {
          "userId": userId,
        },
      );

      return AttendanceStatusModel.fromJson(response);
    } catch (e) {
      print("Toggle Punch Error : $e");
      return null;
    }
  }
}