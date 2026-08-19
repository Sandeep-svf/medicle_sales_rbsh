import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../Tour & Plans/TeritoryModule/model/beat_model.dart';
import '../model/SalesChartDashboardModel.dart';
import '../model/dashboard_beat_model.dart';
import '../widgets/dashboard_beat_bottom_sheet.dart';

class DashboardController extends GetxController {
  Rx<DashboardResponse?> dashboardData = Rx<DashboardResponse?>(null); // Reactive data
  RxBool isLoading = true.obs; // Reactive loading state

  //------------------------------------------------------------
// Dashboard Beat Change
//------------------------------------------------------------

  final RxList<DashboardBeatModel> dashboardBeats =
      <DashboardBeatModel>[].obs;

  final Rxn<DashboardBeatModel> dashboardSelectedBeat =
  Rxn<DashboardBeatModel>();

  final RxBool dashboardBeatLoading = false.obs;

  final RxBool dashboardBeatChanging = false.obs;

  final TextEditingController dashboardBeatSearchController =
  TextEditingController();

  final RxString dashboardBeatSearch = ''.obs;

  final RxList<DashboardBeatModel> dashboardFilteredBeats =
      <DashboardBeatModel>[].obs;

  final TextEditingController dashboardBeatReasonController =
  TextEditingController();



  final String _debugPrefix = '[DashboardController]';

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData('yourBarrierTokenHere'); // Call the function here to fetch data
  }

  Future<void> changeDashboardBeat({
    required String reason,
  }) async {
    try {
      dashboardBeatChanging.value = true;

      final authManager = AuthManager();
      final token = await authManager.getAuthToken();

      final dayId = dashboardData.value?.data?.todayBeatAssigned?.dayId;

      final selectedBeat = dashboardSelectedBeat.value;

      if (dayId == null || selectedBeat == null) {
        Get.snackbar(
          "Error",
          "Please select a beat.",
        );
        return;
      }

      final response = await http.post(
        Uri.parse(
          "${THttpHelper.baseUrl}/tour-plans/day/$dayId/change-request",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "reason": reason,
          "beat_id_1": selectedBeat.id,
          "beat_id_2": null,
          "day_type": "Field",
        }),
      );

      print("$_debugPrefix Change Beat Status : ${response.statusCode}");
      print("$_debugPrefix Change Beat Response : ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final json = jsonDecode(response.body);

        final bool autoApproved =
            json["autoApproved"] ?? false;

        final String message =
            json["message"] ?? "Success";

        Get.back();

        if (autoApproved) {
          Get.snackbar(
            "Beat Updated",
            message,
            backgroundColor: Colors.green.shade100,
          );
        } else {
          Get.snackbar(
            "Approval Requested",
            message,
            backgroundColor: Colors.orange.shade100,
          );
        }

        await fetchDashboardData("");

      } else {
        Get.snackbar(
          "Error",
          "Unable to change today's beat.",
        );
      }
    } catch (e) {
      print("$_debugPrefix changeDashboardBeat() : $e");

      Get.snackbar(
        "Error",
        "Something went wrong.",
      );
    } finally {
      dashboardBeatChanging.value = false;
    }
  }


  void filterDashboardBeats(String value) {
    dashboardBeatSearch.value = value;

    if (value.trim().isEmpty) {
      dashboardFilteredBeats.assignAll(dashboardBeats);
      return;
    }

    dashboardFilteredBeats.assignAll(
      dashboardBeats.where(
            (beat) => beat.name.toLowerCase().contains(
          value.toLowerCase(),
        ),
      ),
    );
  }

  void showDashboardBeatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DashboardBeatBottomSheet(),
    );
  }

  Future<void> fetchDashboardBeats() async {
    try {
      dashboardBeatLoading.value = true;

      final authManager = AuthManager();
      final token = await authManager.getAuthToken();

      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/beats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final DashboardBeatResponse beatResponse =
        DashboardBeatResponse.fromJson(jsonData);

        dashboardBeats.assignAll(beatResponse.data);

        dashboardFilteredBeats.assignAll(dashboardBeats);

        print("$_debugPrefix Total Dashboard Beats : ${dashboardBeats.length}");
      } else {
        print(
          "$_debugPrefix Failed to fetch dashboard beats. Status Code: ${response.statusCode}",
        );

        Get.snackbar(
          "Error",
          "Unable to load beats",
        );
      }
    } catch (e) {
      print("$_debugPrefix fetchDashboardBeats() Error: $e");

      Get.snackbar(
        "Error",
        "Something went wrong while loading beats.",
      );
    } finally {
      dashboardBeatLoading.value = false;
    }
  }

  // Fetch data from the server
  Future<void> fetchDashboardData(String barrierToken) async {
    try {
      AuthManager authManager = AuthManager();
      final token = await authManager.getAuthToken();

      // Debug: Log the token being used
      print('$_debugPrefix Fetching data with token: $token');

      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/dashboard/user'), // Replace with actual base URL
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Debug: Log successful response
        print('$_debugPrefix Response received: ${response.body}');

        // If server returns a success response, parse the data
        final Map<String, dynamic> data = json.decode(response.body);
        dashboardData.value = DashboardResponse.fromJson(data); // Update the reactive variable

        print("$_debugPrefix ========== DASHBOARD ==========");
        print("$_debugPrefix Beat : ${dashboardData.value?.data?.todayBeatAssigned?.beatName}");
        print("$_debugPrefix Type : ${dashboardData.value?.data?.todayBeatAssigned?.dayType}");
        print("$_debugPrefix Doctors : ${dashboardData.value?.data?.todayBeatAssigned?.doctorsCount}");
        print("===============================");

        isLoading.value = false;
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> errorData = json.decode(response.body);

        await _handleUnauthorized(
          errorData['msg'] ?? 'Your session has expired. Please Login again.',
        );

      } else {
        // Handle failure, maybe throw an exception
        print('$_debugPrefix Failed to load dashboard data, Status Code: ${response.statusCode}');
        throw Exception('$_debugPrefix Failed to load dashboard data');
      }
    } catch (e) {
      // Handle error
      print('$_debugPrefix Error fetching dashboard data: $e');
      isLoading.value = false;
    }
  }

  Future<void> _handleUnauthorized(String message) async {
    final authManager = AuthManager();

    await authManager.logout();

    Get.offAll(() => const LoginScreen());

    Get.snackbar(
      "Session Expired",
      "Your session has expired. Please Login again.",
      backgroundColor: Colors.red.shade100,
    );
  }
}
