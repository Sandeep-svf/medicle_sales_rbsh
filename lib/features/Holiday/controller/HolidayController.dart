import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Keep your existing imports
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../../utils/http/http_client.dart';
import '../models/Holiday.dart';

class HolidayController extends GetxController {
  // ==============================================================================
  // 1. DEPENDENCIES
  // ==============================================================================
  final AuthManager _authManager = AuthManager();

  // ==============================================================================
  // 2. REACTIVE STATE (Variables)
  // ==============================================================================

  // Filter States (equivalent to your StateProviders)
  var selectedType = Rxn<HolidayType>(); // Nullable reactive variable
  var selectedYear = 2026.obs;

  // Data States (equivalent to AsyncValue data/loading/error)
  var holidays = <Holiday>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ==============================================================================
  // 3. LIFECYCLE (The "Watch" Logic)
  // ==============================================================================
  @override
  void onInit() {
    super.onInit();

    // Initial Fetch
    fetchHolidays();

    //  WORKERS: This mimics Riverpod's "ref.watch".
    // Whenever selectedType or selectedYear changes, fetchHolidays() runs automatically.
    ever(selectedType, (_) => fetchHolidays());
    ever(selectedYear, (_) => fetchHolidays());
  }

  // ==============================================================================
  // 4. API LOGIC
  // ==============================================================================
  Future<void> fetchHolidays() async {
    // 1. Set Loading State
    isLoading.value = true;
    errorMessage.value = ''; // Clear previous errors

    try {
      //  GET TOKEN
      final String? token = await _authManager.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Auth token not found');
      }

      //  PREPARE QUERY
      // We read the current values from our reactive variables (.value)
      final Map<String, String> queryParams = {
        'year': selectedYear.value.toString(),
      };

      if (selectedType.value != null && selectedType.value != HolidayType.Unknown) {
        queryParams['type'] = selectedType.value!.apiValue!;
      }

      //  BUILD URL
      final Uri uri = Uri.parse(
        '${THttpHelper.baseUrl}/holidays/calendar',
      ).replace(queryParameters: queryParams);

      //  CALL API
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      //  HANDLE RESPONSE
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final List list = body['data'];
          // Update the reactive list
          holidays.value = list.map((e) => Holiday.fromJson(e)).toList();
        } else {
          throw Exception('API success=false');
        }
      } else {
        throw Exception('HTTP error ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      holidays.clear(); // Clear list on error if desired
    } finally {
      // Turn off loading
      isLoading.value = false;
    }
  }

  // Helper methods to update filters from UI (optional, but cleaner)
  void setType(HolidayType? type) => selectedType.value = type;
  void setYear(int year) => selectedYear.value = year;
}