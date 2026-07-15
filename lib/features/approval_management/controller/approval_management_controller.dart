import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/local_storage/auth_manager.dart';
import '../model/collaboration_request_model.dart';
import '../model/pending_approval_model.dart';
import '../service/approval_management_service.dart';



class ApprovalManagementController extends GetxController {
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
    loadData();
  }

  /// ------------------------------
  /// Initial Load
  /// ------------------------------

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      userRole.value = await AuthManager().getUserRole() ?? "";

      if (!isUser) {
        await fetchPendingApprovals();
      }

      await fetchCollaborationRequests();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ------------------------------
  /// Refresh
  /// ------------------------------

  Future<void> refreshData() async {
    pendingApprovals.clear();
    collaborations.clear();

    await loadData();
  }

  /// ------------------------------
  /// Pending Approvals
  /// ------------------------------

  Future<void> fetchPendingApprovals() async {
    pendingApprovals.value =
    await _service.fetchPendingApprovals();
  }

  /// ------------------------------
  /// Collaboration
  /// ------------------------------

  Future<void> fetchCollaborationRequests() async {
    collaborations.value =
    await _service.fetchIncomingCollaborations();
  }

  /// ------------------------------
  /// Approve Tour
  /// ------------------------------

  Future<void> approveTour({
    required PendingApprovalModel plan,
    required String comments,
  }) async {
    try {
      isApproving.value = true;

      await _service.approveTourPlan(
        id: plan.id,
        comments: comments,
      );

      pendingApprovals.removeWhere(
            (e) => e.id == plan.id,
      );

      Get.snackbar(
        "Success",
        "Tour Plan Approved Successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
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
      isReturning.value = true;

      await _service.returnTourPlan(
        id: plan.id,
        comments: comments,
      );

      pendingApprovals.removeWhere(
            (e) => e.id == plan.id,
      );

      Get.snackbar(
        "Success",
        "Tour Plan Returned Successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
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
      isResponding.value = true;

      await _service.respondCollaboration(
        id: request.id,
        action: accept ? "accept" : "reject",
      );

      collaborations.removeWhere(
            (e) => e.id == request.id,
      );

      Get.snackbar(
        "Success",
        accept
            ? "Collaboration Accepted"
            : "Collaboration Rejected",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
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