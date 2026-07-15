import '../../../../utils/http/http_client.dart';
import '../model/collaboration_request_model.dart';
import '../model/pending_approval_model.dart';


class ApprovalManagementService {
  /// Fetch Pending Tour Plan Approvals
  Future<List<PendingApprovalModel>> fetchPendingApprovals() async {
    final response =
    await THttpHelper.authGet('tour-plans/pending-approvals');

    if (response["success"] == true) {
      return (response["data"] as List)
          .map((e) => PendingApprovalModel.fromJson(e))
          .toList();
    }

    return [];
  }

  /// Approve Tour Plan
  Future<void> approveTourPlan({
    required String id,
    required String comments,
  }) async {
    final response = await THttpHelper.authPost(
      'tour-plans/$id/approve',
      {
        "comments": comments,
      },
    );

    if (response["success"] != true) {
      throw Exception(response["message"] ?? "Unable to approve tour plan.");
    }
  }

  /// Return Tour Plan
  Future<void> returnTourPlan({
    required String id,
    required String comments,
  }) async {
    final response = await THttpHelper.authPost(
      'tour-plans/$id/return',
      {
        "comments": comments,
      },
    );

    if (response["success"] != true) {
      throw Exception(response["message"] ?? "Unable to return tour plan.");
    }
  }

  /// Fetch Incoming Collaboration Requests
  Future<List<CollaborationRequestModel>>
  fetchIncomingCollaborations() async {
    final response = await THttpHelper.authGet(
      'tour-plans/collaboration/incoming',
    );

    if (response["success"] == true) {
      return (response["data"] as List)
          .map((e) => CollaborationRequestModel.fromJson(e))
          .toList();
    }

    return [];
  }

  /// Accept / Reject Collaboration Request
  Future<void> respondCollaboration({
    required String id,
    required String action,
  }) async {
    final response = await THttpHelper.authPost(
      'tour-plans/collaboration/$id/respond',
      {
        "action": action,
      },
    );

    if (response["success"] != true) {
      throw Exception(
          response["message"] ?? "Unable to respond collaboration request.");
    }
  }
}