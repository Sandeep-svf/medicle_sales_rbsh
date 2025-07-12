import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/expenses/models/ExpenseDefaultValueModel.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';


class ScraperSettingsController extends GetxController {
  final scraperSettings = Rxn<ExpenseDefaultValueModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final String apiUrl = "${THttpHelper.baseUrl}/expenses/settings"; // Replace with real URL

  @override
  void onInit() {
    fetchSettings();
    super.onInit();
  }

  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        scraperSettings.value = ExpenseDefaultValueModel.fromJson(json);
      } else {
        errorMessage.value = 'Failed to fetch settings (${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSettings(ExpenseDefaultValueModel updated) async {
    try {
      isLoading.value = true;

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updated.toJson()),
      );

      if (response.statusCode == 200) {
        scraperSettings.value = updated;
        Get.snackbar("Success", "Settings updated");
      } else {
        Get.snackbar("Error", "Failed to update settings");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
