import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../model/HolidayLeaves.dart';
import '../model/LeaveType.dart';

class LeaveController extends GetxController {
  final Dio _dio = Dio();
  final String baseUrl = THttpHelper.baseUrl;

  static const String _tag = "[LeaveController]";

  // --- State Variables ---
  var isLoading = true.obs;
  var isSubmitting = false.obs;

  var leaveTypes = <LeaveType>[].obs;
  var leaveBalances = <LeaveBalance>[].obs;
  var leaveHistory = <LeaveHistory>[].obs;

  // List of Holidays
  var holidays = <HolidayLeaves>[].obs;

  // Computed properties for UI
  var calculatedDays = "0.0".obs;
  var showSandwichNote = false.obs; // NEW: Triggers the warning note

  @override
  void onInit() {
    super.onInit();
    _setupDioAndFetch();
  }

  Future<void> _setupDioAndFetch() async {
    AuthManager authManager = AuthManager();
    final token = await authManager.getAuthToken();

    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    fetchAllData();
  }

  // --- API CALLS ---

  Future<void> fetchAllData() async {
    try {
      isLoading(true);
      await Future.wait([
        _fetchLeaveTypes(),
        _fetchBalances(),
        _fetchMyLeaves(),
        _fetchHolidays(),
      ]);
    } catch (e) {
      print("$_tag Error in fetchAllData: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchHolidays() async {
    try {
      final currentYear = DateTime.now().year;
      final response = await _dio.get('/holidays/calendar', queryParameters: {'year': currentYear});

      if (response.data['success'] == true) {
        List data = response.data['data'];
        holidays.value = data.map((e) => HolidayLeaves.fromJson(e)).toList();
        print("$_tag Fetched ${holidays.length} holidays");
      }
    } catch (e) {
      print("$_tag Error fetching Holidays: $e");
    }
  }

  Future<void> _fetchLeaveTypes() async {
    try {
      final response = await _dio.get('/leave-types', queryParameters: {'isActive': true});
      if (response.data['success'] == true) {
        List data = response.data['data'];
        leaveTypes.value = data.map((e) => LeaveType.fromJson(e)).toList();
      }
    } catch (e) { print("$_tag Error Leave Types: $e"); }
  }

  Future<void> _fetchBalances() async {
    try {
      final response = await _dio.get('/leaves/balance');
      if (response.data['success'] == true) {
        List data = response.data['data'];
        leaveBalances.value = data.map((e) => LeaveBalance.fromJson(e)).toList();
      }
    } catch (e) { print("$_tag Error Balances: $e"); }
  }

  Future<void> _fetchMyLeaves() async {
    try {
      final response = await _dio.get('/leaves/my-leaves');
      if (response.data['success'] == true) {
        List data = response.data['data'];
        leaveHistory.value = data.map((e) => LeaveHistory.fromJson(e)).toList();
      }
    } catch (e) { print("$_tag Error History: $e"); }
  }

  Future<void> applyLeave({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    required bool isHalfDay,
    String? halfDayType, // NEW: Added for Enum
  }) async {
    try {
      isSubmitting(true);
      final body = {
        "leaveTypeId": leaveTypeId,
        "startDate": startDate,
        "endDate": endDate,
        "reason": reason,
        "isHalfDay": isHalfDay,
        "halfDayType": isHalfDay ? (halfDayType ?? "") : "",
        "emergencyContact": { "name": "Admin", "phone": "0000", "relation": "Office" },
        "handoverNotes": "N/A"
      };

      final response = await _dio.post('/leaves/apply', data: body);

      if (response.data['success'] == true) {
        Get.back();
        Get.snackbar("Success", "Leave applied successfully!", backgroundColor: Colors.green.withOpacity(0.2));
        fetchAllData();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to apply: ${e.toString()}", backgroundColor: Colors.red.withOpacity(0.2));
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> cancelLeave(String leaveId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await _dio.put('/leaves/$leaveId/cancel');
      Get.back();

      if (response.data['success'] == true) {
        Get.snackbar("Success", "Leave cancelled", backgroundColor: Colors.green.withOpacity(0.1));
        fetchAllData();
      } else {
        Get.snackbar("Error", response.data['message']);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Failed to cancel");
    }
  }

  // --- HELPER LOGIC ---

  bool isRestDay(DateTime date) {
    if (date.weekday == DateTime.sunday) return true;
    for (var holiday in holidays) {
      if (isSameDay(date, holiday.date)) return true;
    }
    return false;
  }

  bool isDateBlocked(DateTime date) => isRestDay(date);

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // NEW: Sandwich Rule Logic
  void calculateDuration(DateTime? start, DateTime? end, bool isHalfDay) {
    if (start == null || end == null) {
      calculatedDays.value = "0.0";
      showSandwichNote.value = false;
      return;
    }

    double count = 0.0;
    bool sandwichDetected = false;
    DateTime current = start;

    while (current.isBefore(end) || isSameDay(current, end)) {
      bool isHoliday = isRestDay(current);

      if (!isHoliday) {
        count++;
      } else {
        // SANDWICH RULE: Count holiday as leave if it's NOT the first or last day selected
        if (!isSameDay(current, start) && !isSameDay(current, end)) {
          count++;
          sandwichDetected = true;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    if (count > 0 && isHalfDay) {
      count -= 0.5;
    }

    calculatedDays.value = count.toString();
    showSandwichNote.value = sandwichDetected;
  }
}