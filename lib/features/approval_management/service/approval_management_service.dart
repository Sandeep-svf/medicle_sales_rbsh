import 'package:flutter/foundation.dart';

import '../../../../utils/http/http_client.dart';
import '../model/beat_change_request_model.dart';
import '../model/collaboration_request_model.dart';
import '../model/pending_approval_model.dart';

class ApprovalManagementService {
  static const String _tag = "[ApprovalManagementService]";

  /// Fetch Pending Beat Change Requests
  Future<List<BeatChangeRequestModel>>
  fetchPendingBeatChangeRequests() async {
    debugPrint("$_tag GET -> tour-plans/pending-change-requests");

    final response = await THttpHelper.authGet(
      'tour-plans/pending-change-requests',
    );

    debugPrint("$_tag Response: $response");

    if (response["success"] == true) {
      final list = (response["data"] as List?) ?? [];

      debugPrint("$_tag Beat Change Requests Count = ${list.length}");

      return list
          .map((e) => BeatChangeRequestModel.fromJson(e))
          .toList();
    }

    debugPrint("$_tag Request Failed");

    return [];
  }

  /// Fetch Pending Tour Plan Approvals
  Future<List<PendingApprovalModel>> fetchPendingApprovals() async {
    debugPrint("$_tag GET -> tour-plans/pending-approvals");

    final response =
    await THttpHelper.authGet('tour-plans/pending-approvals');

    debugPrint("$_tag Response: $response");

    if (response["success"] == true) {
      final list = (response["data"] as List?) ?? [];

      debugPrint("$_tag Pending Approvals Count = ${list.length}");

      return list
          .map((e) => PendingApprovalModel.fromJson(e))
          .toList();
    }

    debugPrint("$_tag Request Failed");

    return [];
  }

  /// Approve Tour Plan
  Future<void> approveTourPlan({
    required String id,
    required String comments,
  }) async {
    debugPrint("$_tag POST -> tour-plans/$id/approve");

    final response = await THttpHelper.authPost(
      'tour-plans/$id/approve',
      {
        "comments": comments,
      },
    );

    debugPrint("$_tag Response: $response");

    if (response["success"] != true) {
      throw Exception(response["message"] ?? "Unable to approve tour plan.");
    }
  }

  /// Return Tour Plan
  Future<void> returnTourPlan({
    required String id,
    required String comments,
  }) async {
    debugPrint("$_tag POST -> tour-plans/$id/return");

    final response = await THttpHelper.authPost(
      'tour-plans/$id/return',
      {
        "comments": comments,
      },
    );

    debugPrint("$_tag Response: $response");

    if (response["success"] != true) {
      throw Exception(response["message"] ?? "Unable to return tour plan.");
    }
  }

  /// Fetch Incoming Collaboration Requests
  Future<List<CollaborationRequestModel>>
  fetchIncomingCollaborations() async {
    debugPrint("$_tag GET -> tour-plans/collaboration/incoming");

    final response = await THttpHelper.authGet(
      'tour-plans/collaboration/incoming',
    );

    debugPrint("$_tag Response: $response");

    if (response["success"] == true) {
      final list = (response["data"] as List?) ?? [];

      debugPrint("$_tag Collaboration Count = ${list.length}");

      for (int i = 0; i < list.length; i++) {
        debugPrint("$_tag Collaboration[$i] = ${list[i]}");
      }

      final parsed = list
          .map((e) => CollaborationRequestModel.fromJson(e))
          .toList();

      debugPrint("$_tag Parsed Collaboration Count = ${parsed.length}");

      return parsed;
    }

    debugPrint("$_tag Request Failed");

    return [];
  }

  /// Accept / Reject Collaboration Request
  Future<void> respondCollaboration({
    required String id,
    required String action,
  }) async {
    debugPrint("$_tag POST -> tour-plans/collaboration/$id/respond");
    debugPrint("$_tag Action = $action");

    final response = await THttpHelper.authPost(
      'tour-plans/collaboration/$id/respond',
      {
        "action": action,
      },
    );

    debugPrint("$_tag Response: $response");

    if (response["success"] != true) {
      throw Exception(
        response["message"] ??
            "Unable to respond collaboration request.",
      );
    }
  }

  /// Approve / Reject Beat Change Request
  Future<void> respondBeatChangeRequest({
    required String dayId,
    required String action,
    required String comments,
  }) async {
    debugPrint("$_tag POST -> tour-plans/day/$dayId/respond-change-request");
    debugPrint("$_tag Action = $action");
    debugPrint("$_tag Comments = $comments");

    final response = await THttpHelper.authPost(
      'tour-plans/day/$dayId/respond-change-request',
      {
        "action": action,
        "comments": comments,
      },
    );

    debugPrint("$_tag Response: $response");

    if (response["success"] != true) {
      throw Exception(
        response["message"] ??
            "Unable to respond to beat change request.",
      );
    }
  }
}