import 'package:dio/dio.dart';
import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../model/beat_model.dart';
import '../model/available_user_model.dart';

class TourPlanService {
  final Dio _dio = Dio();

  Future<void> _setupHeaders() async {
    final token = await AuthManager().getAuthToken();
    _dio.options.baseUrl = THttpHelper.baseUrl;
    _dio.options.headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  Future<List<BeatModel>> getBeats() async {
    await _setupHeaders();
    try {
      final response = await _dio.get('/beats');
      if (response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((e) => BeatModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("[TourPlanService] getBeats Error: $e");
    }
    return [];
  }

  Future<List<AvailableUserModel>> getAvailableUsers(DateTime date) async {
    await _setupHeaders();
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      final response = await _dio.get(
        '/tour-plans/users/availability',
        queryParameters: {"date": formattedDate},
      );
      if (response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((e) => AvailableUserModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("[TourPlanService] getAvailableUsers Error: $e");
    }
    return [];
  }

  Future<String?> saveDraft(Map<String, dynamic> body) async {
    await _setupHeaders();
    try {
      final response = await _dio.post('/tour-plans/draft', data: body);
      if (response.data['success'] == true) {
        return response.data['data']['id'];
      }
    } catch (e) {
      print("[TourPlanService] saveDraft Error: $e");
    }
    return null;
  }

  Future<bool> submitDraft(String draftId) async {
    await _setupHeaders();
    try {
      final response = await _dio.post('/tour-plans/$draftId/submit');
      return response.data['success'] == true;
    } catch (e) {
      print("[TourPlanService] submitDraft Error: $e");
    }
    return false;
  }
}