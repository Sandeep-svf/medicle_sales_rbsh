import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/local_storage/auth_manager.dart';
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
    collaborations.clear();

    await loadData();
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

  Future<void> fetchCollaborationRequests() async {
    debugPrint("$_tag fetchCollaborationRequests()");

    final data = await _service.fetchIncomingCollaborations();

    debugPrint("$_tag API returned ${data.length} collaboration requests");

    for (final item in data) {
      debugPrint(
        "$_tag Collaboration -> "
            "id=${item.id}, "
            "status=${item.collaborationStatus}",
      );
    }

    collaborations.assignAll(data);

    debugPrint(
      "$_tag collaborations updated. Count=${collaborations.length}",
    );
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