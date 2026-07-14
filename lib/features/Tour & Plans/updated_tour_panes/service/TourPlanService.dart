import '../../../../utils/http/http_client.dart';

import '../model/available_user_model.dart';
import '../model/beat_model.dart';
import '../model/tour_plan_model.dart';

class TourPlanService {

  /// -----------------------------------------------------------
  /// Beats
  /// -----------------------------------------------------------

  Future<List<BeatModel>> getBeats() async {
    try {
      final response =
      await THttpHelper.authGet("beats");

      if (response["success"] == true) {
        final List data =
            response["data"] ?? [];

        return data
            .map(
              (e) => BeatModel.fromJson(e),
        )
            .toList();
      }
    } catch (e) {
      print(
        "[TourPlanService] getBeats : $e",
      );
    }

    return [];
  }

  /// -----------------------------------------------------------
  /// Available Users
  /// -----------------------------------------------------------

  Future<List<AvailableUserModel>>
  getAvailableUsers(
      DateTime date,
      ) async {
    try {
      final formattedDate =
          "${date.year}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')}";

      final response =
      await THttpHelper.authGet(
        "tour-plans/users/availability?date=$formattedDate",
      );

      if (response["success"] == true) {
        final List data =
            response["data"] ?? [];

        return data
            .map(
              (e) =>
              AvailableUserModel.fromJson(e),
        )
            .toList();
      }
    } catch (e) {
      print(
        "[TourPlanService] getAvailableUsers : $e",
      );
    }

    return [];
  }

  /// -----------------------------------------------------------
  /// Save Draft
  /// -----------------------------------------------------------

  Future<String?> saveDraft(
      Map<String, dynamic> body,
      ) async {
    try {
      final response =
      await THttpHelper.authPost(
        "tour-plans/draft",
        body,
      );

      if (response["success"] == true) {
        return response["data"]["id"];
      }
    } catch (e) {
      print(
        "[TourPlanService] saveDraft : $e",
      );
    }

    return null;
  }

  /// -----------------------------------------------------------
  /// Submit Draft
  /// -----------------------------------------------------------

  Future<bool> submitDraft(
      String draftId,
      ) async {
    try {
      final response =
      await THttpHelper.authPost(
        "tour-plans/$draftId/submit",
        {},
      );

      return response["success"] == true;
    } catch (e) {
      print(
        "[TourPlanService] submitDraft : $e",
      );
    }

    return false;
  }

  /// -----------------------------------------------------------
  /// Tour Plan List
  /// -----------------------------------------------------------

  Future<List<TourPlanModel>>
  getTourPlans() async {
    try {
      final response =
      await THttpHelper.authGet(
        "tour-plans",
      );

      if (response["success"] == true) {
        final List data =
            response["data"] ?? [];

        return data
            .map(
              (e) =>
              TourPlanModel.fromJson(e),
        )
            .toList();
      }
    } catch (e) {
      print(
        "[TourPlanService] getTourPlans : $e",
      );
    }

    return [];
  }

  /// -----------------------------------------------------------
  /// Tour Plan Details
  /// -----------------------------------------------------------

  Future<TourPlanModel?>
  getTourPlanDetails(
      String id,
      ) async {
    try {
      final response =
      await THttpHelper.authGet(
        "tour-plans/$id",
      );

      if (response["success"] == true) {
        return TourPlanModel.fromJson(
          response["data"],
        );
      }
    } catch (e) {
      print(
        "[TourPlanService] getTourPlanDetails : $e",
      );
    }

    return null;
  }
}