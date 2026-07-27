import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../models/doctor_details_model.dart';

import 'dart:convert';
import 'dart:developer';


class DoctorDetailsController extends GetxController {
  DoctorDetailsController(this.doctorId);

  final String doctorId;

  static const String _baseUrl = THttpHelper.baseUrl;

  final AuthManager authManager = AuthManager();

  final RxBool isLoading = false.obs;

  final Rxn<DoctorDetailsModel> doctor = Rxn<DoctorDetailsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchDoctor();
  }

  Future<void> fetchDoctor() async {
    try {
      isLoading.value = true;

      final token = await authManager.getAuthToken();

      final url = "$_baseUrl/doctors/$doctorId";

      log(
        "GET => $url",
        name: "DoctorDetailsController",
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      log(
        "Status Code => ${response.statusCode}",
        name: "DoctorDetailsController",
      );

      log(
        "Raw Response => ${response.body}",
        name: "DoctorDetailsController",
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
        jsonDecode(response.body);

        log(
          "Parsed JSON => $json",
          name: "DoctorDetailsController",
        );

        if (json["success"] == true) {
          try {
            doctor.value = DoctorDetailsModel.fromJson(json["data"]);

            log(
              "Doctor parsed successfully.",
              name: "DoctorDetailsController",
            );
          } catch (e, stack) {
            log(
              "Model Parsing Failed",
              name: "DoctorDetailsController",
              error: e,
              stackTrace: stack,
            );

            log(
              "Problematic Data => ${json["data"]}",
              name: "DoctorDetailsController",
            );

            rethrow;
          }
        } else {
          Get.snackbar(
            "Error",
            json["message"] ?? "Failed to load doctor",
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Server Error ${response.statusCode}",
        );
      }
    } catch (e, stack) {
      log(
        "fetchDoctor Exception",
        name: "DoctorDetailsController",
        error: e,
        stackTrace: stack,
      );

      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDoctor() async {
    await fetchDoctor();
  }
}