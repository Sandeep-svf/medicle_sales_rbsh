import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import 'dart:convert';
import '../../../utils/http/http_client.dart';
import '../../authentication/controllers/AuthController.dart';
import '../models/DoctorModelList.dart';

class DoctorListController extends GetxController {
  var isLoading = false.obs;

  // ORIGINAL LIST (Used by your other screens - DO NOT CHANGE)
  var doctorList = <Doctor>[].obs;

  // NEW: FILTERED LIST (Used specifically for the Search Sheet)
  var filteredDoctors = <Doctor>[].obs;

  var totalDoctors = 0.obs;

  // ================= FILTERS =================

  var selectedFilter = "all".obs; // all | visited | unvisited
  // all | A | B | C
  var selectedPriority = "all".obs;

  // Priority Filter (all | A | B | C)
  var selectedPriorityFilter = "all".obs;

  var fromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;

  var toDate = DateTime.now().obs;



  static const String _baseUrl = THttpHelper.baseUrl;
  AuthManager authManager = AuthManager();
  late String headOffice="";

  Future<void> applyFilter() async {
    switch (selectedFilter.value) {
      case "visited":
        await fetchVisitedDoctors();
        break;

      case "unvisited":
        await fetchUnvisitedDoctors();
        break;

      default:
        await fetchDoctorList();
        break;
    }

    // Apply Priority Filter
    if (selectedPriority.value != "all") {
      final filtered = doctorList.where((doctor) {
        return doctor.priority == selectedPriority.value;
      }).toList();

      filteredDoctors.assignAll(filtered);
      totalDoctors.value = filtered.length;
    } else {
      filteredDoctors.assignAll(doctorList);
      totalDoctors.value = doctorList.length;
    }
  }

  Future<void> fetchVisitedDoctors() async {
    try {
      isLoading.value = true;

      final token = await authManager.getAuthToken();

      final response = await http.post(
        Uri.parse("$_baseUrl/doctors/visited-in-range"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "from": DateFormat('yyyy-MM-dd').format(fromDate.value),
          "to": DateFormat('yyyy-MM-dd').format(toDate.value),
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final List<dynamic> data = jsonResponse["data"] ?? [];

        final doctors =
        data.map((e) => Doctor.fromJson(e)).toList();

        totalDoctors.value =
            jsonResponse["count"] ?? doctors.length;

        doctorList.assignAll(doctors);
        filteredDoctors.assignAll(doctors);
      } else {
        Get.snackbar(
          "Error",
          "Unable to fetch visited doctors",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnvisitedDoctors() async {
    try {
      isLoading.value = true;

      final token = await authManager.getAuthToken();

      final response = await http.post(
        Uri.parse("$_baseUrl/doctors/unvisited-in-range"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "from": DateFormat('yyyy-MM-dd').format(fromDate.value),
          "to": DateFormat('yyyy-MM-dd').format(toDate.value),
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final List<dynamic> data = jsonResponse["data"] ?? [];

        final doctors =
        data.map((e) => Doctor.fromJson(e)).toList();

        totalDoctors.value =
            jsonResponse["count"] ?? doctors.length;

        doctorList.assignAll(doctors);
        filteredDoctors.assignAll(doctors);
      } else {
        Get.snackbar(
          "Error",
          "Unable to fetch unvisited doctors",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetFilters() async {
    selectedFilter.value = "all";
    selectedPriority.value = "all";

    fromDate.value = DateTime.now().subtract(
      const Duration(days: 30),
    );

    toDate.value = DateTime.now();

    await fetchDoctorList();
  }

  Future<void> assignAreaToDoctor({
    required String doctorId,
    required String areaId,
  }) async {
    try {
      final token =
      await authManager.getAuthToken();

      final response = await http.put(
        Uri.parse(
          "$_baseUrl/doctors/$doctorId",
        ),
        headers: {
          "Content-Type":
          "application/json",
          "Authorization":
          "Bearer $token",
        },
        body: jsonEncode({
          "areaId": areaId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchDoctorList();

        Get.snackbar(
          "Success",
          "Area Assigned",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  // PLACE THIS INSIDE YOUR DoctorListController CLASS
  Future<String?> createNewArea({
    required String name,
    required String pincode,
    required String postOffice,
    required String headOfficeId,
  }) async {
    try {
      isLoading.value = true;

      final token =
      await authManager.getAuthToken();

      final response = await http.post(
        Uri.parse("$_baseUrl/areas"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "pincode": pincode,
          "post_office": postOffice,
          "head_office_id": headOfficeId,
        }),
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200) {

        final jsonResponse =
        jsonDecode(response.body);

        final String createdAreaId =
        jsonResponse["data"]["id"];

        Get.snackbar(
          "Success",
          "Area created successfully!",
        );

        return createdAreaId;
      }

      Get.snackbar(
        "Error",
        "Failed creating area",
      );

      return null;

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

      return null;

    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> fetchAreas() async {
    try {
      final token = await authManager.getAuthToken();

      final response = await http.get(
        Uri.parse("$_baseUrl/areas"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(response.body);

        return jsonResponse["data"] ?? [];
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchDoctorList() async {
    print("Doctors Data: Fetching doctor list...");
    try {
      isLoading.value = true;

      // headOffice = (await authManager.getHeadOffice())!;
      // final headOffice = (await authManager.getHeadOffice()) ?? '';

      final token = await authManager.getAuthToken();

      print("Doctors Data: headOffice $headOffice");
      print("Doctors Data: $_baseUrl/api/doctors/my-doctors");
      final response = await http.get(
        Uri.parse("$_baseUrl/doctors/my-doctors"),
        headers: {"Content-Type": "application/json",
          'Authorization': 'Bearer $token'},
      );

      print("Response: ${response.body}");

      if (Get.isDialogOpen ?? false) Get.back(); // Close the loading dialog

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
        jsonDecode(response.body);

        final List<dynamic> jsonData =
            jsonResponse['data'] ?? [];

        print("Doctors Data: $jsonData");

        final List<Doctor> loadedData =
        jsonData.map((e) => Doctor.fromJson(e)).toList();

        totalDoctors.value =
            jsonResponse["count"] ?? loadedData.length;

        doctorList.assignAll(loadedData);
        filteredDoctors.assignAll(loadedData);
      } else {
        Get.snackbar("Error", "Failed to load doctors: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Doctors Data: falling in catch block $e");
      if (Get.isDialogOpen ?? false) Get.back(); // Ensure dialog is closed
      Get.snackbar("Error", "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      print("Doctors Data: Falling in finally block");
      isLoading.value = false;
    }
  }

  // NEW: Search Logic
  void filterDoctors(String query) {
    if (query.isEmpty) {
      // Reset to full list
      filteredDoctors.assignAll(doctorList);
    } else {
      // Filter list
      filteredDoctors.assignAll(doctorList.where((doctor) {
        return doctor.name.toLowerCase().contains(query.toLowerCase());
      }).toList());
    }
  }
}