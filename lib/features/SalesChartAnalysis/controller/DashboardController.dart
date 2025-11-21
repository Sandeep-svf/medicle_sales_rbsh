import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../model/SalesChartDashboardModel.dart';

class DashboardController extends GetxController {
  Rx<DashboardResponse?> dashboardData = Rx<DashboardResponse?>(null); // Reactive data
  RxBool isLoading = true.obs; // Reactive loading state

  final String _debugPrefix = '[DashboardController]';


  @override
  void onInit() {
    super.onInit();
    fetchDashboardData('yourBarrierTokenHere'); // Call the function here to fetch data
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
        isLoading.value = false;
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
}
