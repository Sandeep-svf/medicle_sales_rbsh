import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/local_storage/auth_manager.dart';
import '../model/beat_change_request_model.dart';
import '../model/collaboration_request_model.dart';
import '../model/pending_approval_model.dart';
import '../service/approval_management_service.dart';

class ApprovalManagementController extends GetxController {
  static const String _tag = "[ApprovalManagementController]";

  final ApprovalManagementService _service = ApprovalManagementService();

  /// Loading
  final RxBool isLoading = false.obs;

  /// Button loading
  final RxBool isApproving = false.obs;
  final RxBool isReturning = false.obs;
  final RxBool isResponding = false.obs;

  /// Role
  final RxString userRole = "".obs;

  /// Tab Index
  final RxInt selectedTab = 0.obs;

  /// Pending Tour Plans
  final RxList<PendingApprovalModel> pendingApprovals =
      <PendingApprovalModel>[].obs;

  /// Collaboration Requests
  final RxList<CollaborationRequestModel> collaborations =
      <CollaborationRequestModel>[].obs;

  //------------------------------------------------------------
// Beat Change Requests
//------------------------------------------------------------

  final RxList<BeatChangeRequestModel> beatChangeRequests =
      <BeatChangeRequestModel>[].obs;

  final RxBool isBeatResponding = false.obs;

  bool get isUser => userRole.value.toLowerCase() == "user";

  @override
  void onInit() {
    super.onInit();
    debugPrint("$_tag onInit()");
    loadData();
  }

  /// ------------------------------
  /// Initial Load
  /// ------------------------------

  Future<void> loadData() async {
    try {
      debugPrint("$_tag ===============================");
      debugPrint("$_tag loadData() Started");

      isLoading.value = true;

      userRole.value = await AuthManager().getUserRole() ?? "";

      debugPrint("$_tag User Role : ${userRole.value}");
      debugPrint("$_tag isUser : $isUser");

      if (!isUser) {
        await fetchPendingApprovals();

        await fetchPendingBeatChangeRequests();
      }

      await fetchCollaborationRequests();

      debugPrint(
        "$_tag Load Completed -> Pending=${pendingApprovals.length}, Collaboration=${collaborations.length}",
      );
    } catch (e, s) {
      debugPrint("$_tag ERROR in loadData()");
      debugPrint("$_tag $e");
      debugPrint("$s");

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      debugPrint("$_tag isLoading = false");
      debugPrint("$_tag ===============================");
    }
  }

  /// ------------------------------
  /// Refresh
  /// ------------------------------

  Future<void> refreshData() async {
    debugPrint("$_tag Refresh Requested");

    pendingApprovals.clear();
    beatChangeRequests.clear();
    collaborations.clear();

    await loadData();
  }


  /// ------------------------------
  /// Pending Beat Change Requests
  /// ------------------------------

  Future<void> fetchPendingBeatChangeRequests() async {
    debugPrint("$_tag fetchPendingBeatChangeRequests()");

    final data = await _service.fetchPendingBeatChangeRequests();

    debugPrint(
      "$_tag API returned ${data.length} Beat Change Requests",
    );

    beatChangeRequests.assignAll(data);

    debugPrint(
      "$_tag beatChangeRequests updated. Count=${beatChangeRequests.length}",
    );
  }

  /// ------------------------------
  /// Respond Beat Change Request
  /// ------------------------------

  Future<void> respondBeatChangeRequest({
    required BeatChangeRequestModel request,
    required bool approve,
    required String comments,
  }) async {
    try {
      debugPrint(
        "$_tag Respond Beat Change -> "
            "id=${request.id}, "
            "approve=$approve",
      );

      isBeatResponding.value = true;

      await _service.respondBeatChangeRequest(
        dayId: request.id,
        action: approve ? "approve" : "reject",
        comments: comments,
      );

      beatChangeRequests.removeWhere(
            (e) => e.id == request.id,
      );

      Get.snackbar(
        "Success",
        approve
            ? "Beat Change Approved"
            : "Beat Change Rejected",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, s) {
      debugPrint("$_tag Beat Change Error");
      debugPrint("$e");
      debugPrint("$s");

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isBeatResponding.value = false;
    }
  }

  /// ------------------------------
  /// Pending Approvals
  /// ------------------------------

  Future<void> fetchPendingApprovals() async {
    debugPrint("$_tag fetchPendingApprovals()");

    final data = await _service.fetchPendingApprovals();

    debugPrint("$_tag API returned ${data.length} pending approvals");

    for (final item in data) {
      debugPrint(
        "$_tag Pending -> "
            "id=${item.id}, "
            "status=${item.status}, "
            "employee=${item.approvedByName}",
      );
    }

    pendingApprovals.assignAll(data);

    debugPrint(
      "$_tag pendingApprovals updated. Count=${pendingApprovals.length}",
    );
  }

  /// ------------------------------
  /// Collaboration
  /// ------------------------------

  /// ------------------------------
  /// Collaboration
  /// ------------------------------

  Future<void> fetchCollaborationRequests() async {
    debugPrint("$_tag ========================================");
    debugPrint("$_tag fetchCollaborationRequests() Started");

    final data = await _service.fetchIncomingCollaborations();

    debugPrint("$_tag Service returned ${data.length} collaboration request(s)");

    for (int i = 0; i < data.length; i++) {
      final item = data[i];

      debugPrint(
        "$_tag Item[$i] -> "
            "id=${item.id}, "
            "status=${item.collaborationStatus}",
      );
    }

    collaborations.assignAll(data);

    debugPrint(
      "$_tag collaborations.assignAll() completed",
    );

    debugPrint(
      "$_tag collaborations.length = ${collaborations.length}",
    );

    for (int i = 0; i < collaborations.length; i++) {
      final item = collaborations[i];

      debugPrint(
        "$_tag Observable[$i] -> "
            "id=${item.id}, "
            "status=${item.collaborationStatus}",
      );
    }

    debugPrint("$_tag ========================================");
  }

  /// ------------------------------
  /// Approve Tour
  /// ------------------------------

  Future<void> approveTour({
    required PendingApprovalModel plan,
    required String comments,
  }) async {
    try {
      debugPrint("$_tag Approving Tour -> ${plan.id}");

      isApproving.value = true;

      await _service.approveTourPlan(
        id: plan.id,
        comments: comments,
      );

      pendingApprovals.removeWhere(
            (e) => e.id == plan.id,
      );

      debugPrint(
        "$_tag Tour Approved. Remaining Pending=${pendingApprovals.length}",
      );

      Get.snackbar(
        "Success",
        "Tour Plan Approved Successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, s) {
      debugPrint("$_tag ERROR Approving Tour");
      debugPrint("$_tag $e");
      debugPrint("$s");

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isApproving.value = false;
    }
  }

  /// ------------------------------
  /// Return Tour
  /// ------------------------------

  Future<void> returnTour({
    required PendingApprovalModel plan,
    required String comments,
  }) async {
    try {
      debugPrint("$_tag Returning Tour -> ${plan.id}");

      isReturning.value = true;

      await _service.returnTourPlan(
        id: plan.id,
        comments: comments,
      );

      pendingApprovals.removeWhere(
            (e) => e.id == plan.id,
      );

      debugPrint(
        "$_tag Tour Returned. Remaining Pending=${pendingApprovals.length}",
      );

      Get.snackbar(
        "Success",
        "Tour Plan Returned Successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, s) {
      debugPrint("$_tag ERROR Returning Tour");
      debugPrint("$_tag $e");
      debugPrint("$s");

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isReturning.value = false;
    }
  }

  /// ------------------------------
  /// Collaboration Response
  /// ------------------------------

  Future<void> respondCollaboration({
    required CollaborationRequestModel request,
    required bool accept,
  }) async {
    try {
      debugPrint(
        "$_tag Respond Collaboration -> id=${request.id}, accept=$accept",
      );

      isResponding.value = true;

      await _service.respondCollaboration(
        id: request.id,
        action: accept ? "accept" : "reject",
      );

      collaborations.removeWhere(
            (e) => e.id == request.id,
      );

      debugPrint(
        "$_tag Collaboration Updated. Remaining=${collaborations.length}",
      );

      Get.snackbar(
        "Success",
        accept
            ? "Collaboration Accepted"
            : "Collaboration Rejected",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, s) {
      debugPrint("$_tag ERROR Responding Collaboration");
      debugPrint("$_tag $e");
      debugPrint("$s");

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isResponding.value = false;
    }
  }
}