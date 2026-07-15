import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/attendance_status_model.dart';
import '../services/attendance_service.dart';
import '../wigets/punch_in_dialog.dart';

class AttendanceController extends GetxController {
  static AttendanceController get to => Get.find();

  static const String _tag = "[AttendanceController]";

  final AttendanceService _service = AttendanceService.instance;

  final RxBool isLoading = false.obs;
  final RxBool isPunching = false.obs;

  final Rxn<AttendanceStatusModel> attendance = Rxn();

  final RxBool hasShownDialog = false.obs;

  bool get isPunchedIn => attendance.value?.isPunchedIn ?? false;

  @override
  void onInit() {
    super.onInit();

    debugPrint("$_tag Initialized");

    checkTodayStatus();
  }

  Future<void> checkTodayStatus() async {
    debugPrint("$_tag Checking today's attendance status...");

    isLoading.value = true;

    try {
      final response = await _service.getTodayStatus();

      if (response == null) {
        debugPrint("$_tag Status API returned NULL");
        return;
      }

      attendance.value = response;

      debugPrint(
          "$_tag Status Loaded -> ${response.status}");

      debugPrint(
          "$_tag Needs Punch In -> ${response.needsPunchIn}");

      if (response.needsPunchIn && !hasShownDialog.value) {
        debugPrint("$_tag Opening Punch In Dialog");

        hasShownDialog.value = true;

        _showPunchDialog();
      } else {
        debugPrint("$_tag Punch dialog not required.");
      }
    } catch (e, stackTrace) {
      debugPrint("$_tag Error checking attendance");
      debugPrint("$_tag $e");

      if (kDebugMode) {
        debugPrintStack(
          stackTrace: stackTrace,
        );
      }
    } finally {
      isLoading.value = false;

      debugPrint("$_tag Status check completed");
    }
  }

  void _showPunchDialog() {
    debugPrint("$_tag Showing Punch In Dialog");

    Get.dialog(
      const PunchInDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> punchIn() async {
    if (isPunching.value) {
      debugPrint("$_tag Punch already in progress.");
      return;
    }

    debugPrint("$_tag Punch In Started");

    isPunching.value = true;

    try {
      final response = await _service.togglePunch();

      if (response == null) {
        debugPrint("$_tag Punch API returned NULL");

        Get.snackbar(
          "Error",
          "Unable to punch in.",
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      attendance.value = response;

      debugPrint(
          "$_tag Punch Successful -> ${response.status}");

      if (response.isPunchedIn) {
        debugPrint("$_tag Closing Punch Dialog");

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        Get.snackbar(
          "Success",
          "Punched in successfully.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        debugPrint(
            "$_tag Unexpected status received -> ${response.status}");
      }
    } catch (e, stackTrace) {
      debugPrint("$_tag Punch In Failed");
      debugPrint("$_tag $e");

      if (kDebugMode) {
        debugPrintStack(
          stackTrace: stackTrace,
        );
      }
    } finally {
      isPunching.value = false;

      debugPrint("$_tag Punch process completed");
    }
  }
}