import 'package:dio/dio.dart';

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';

import '../model/available_user_model.dart';
import '../model/beat_model.dart';

class MtpService {
  final Dio dio = Dio();

  Future<void> init() async {
    final token =
    await AuthManager().getAuthToken();

    dio.options.baseUrl =
        THttpHelper.baseUrl;

    dio.options.headers = {
      "Authorization":
      "Bearer $token",
      "Content-Type":
      "application/json",
    };
  }

  Future<List<BeatModel>>
  getBeats() async {
    await init();

    final response =
    await dio.get('/beats');

    final List data =
        response.data['data'] ?? [];

    return data
        .map(
          (e) => BeatModel.fromJson(e),
    )
        .toList();
  }

  Future<List<AvailableUserModel>>
  getAvailableUsers(
      DateTime date,
      ) async {
    await init();

    final response = await dio.get(
      '/tour-plans/users/availability',
      queryParameters: {
        "date":
        date
            .toIso8601String()
            .split("T")
            .first,
      },
    );

    final List data =
        response.data['data'] ?? [];

    return data
        .map(
          (e) =>
          AvailableUserModel.fromJson(
            e,
          ),
    )
        .where(
          (e) => e.available,
    )
        .toList();
  }

  Future<String> saveDraft(
      Map<String, dynamic> body,
      ) async {
    await init();

    final response =
    await dio.post(
      '/tour-plans/draft',
      data: body,
    );

    return response
        .data['data']?['id'] ??
        '';
  }

  Future<void> submitPlan(
      String draftId,
      ) async {
    await init();

    await dio.post(
      '/tour-plans/$draftId/submit',
    );
  }
}