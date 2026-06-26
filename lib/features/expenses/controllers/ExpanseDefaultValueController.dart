import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/expenses/models/ExpenseDefaultValueModel.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

class ScraperSettingsController extends GetxController {
  static const String _tag = 'ScraperSettingsController';

  final scraperSettings = Rxn<ExpenseDefaultValueModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final String apiUrl = "${THttpHelper.baseUrl}/expenses/settings";

  @override
  void onInit() {
    print('[$_tag] onInit');
    fetchSettings();
    super.onInit();
  }

  Future<void> fetchSettings() async {
    try {
      print('[$_tag] Fetching settings from: $apiUrl');

      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(Uri.parse(apiUrl));

      print('[$_tag] Response Status: ${response.statusCode}');
      print('[$_tag] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        print('[$_tag] Parsed JSON: $json');

        scraperSettings.value = ExpenseDefaultValueModel.fromJson(json);

        print(
          '[$_tag] Settings Loaded: ${scraperSettings.value?.toJson()}',
        );
      } else {
        errorMessage.value =
        'Failed to fetch settings (${response.statusCode})';

        print('[$_tag] Error: ${errorMessage.value}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error: ${e.toString()}';

      print('[$_tag] Exception: $e');
      print('[$_tag] StackTrace: $stackTrace');
    } finally {
      isLoading.value = false;
      print('[$_tag] Loading Complete');
    }
  }

  Future<void> updateSettings(ExpenseDefaultValueModel updated) async {
    try {
      print('[$_tag] Updating Settings');
      print('[$_tag] Request Body: ${jsonEncode(updated.toJson())}');

      isLoading.value = true;

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updated.toJson()),
      );

      print('[$_tag] Update Status: ${response.statusCode}');
      print('[$_tag] Update Response: ${response.body}');

      if (response.statusCode == 200) {
        scraperSettings.value = updated;

        print('[$_tag] Settings Updated Successfully');

        Get.snackbar("Success", "Settings updated");
      } else {
        print('[$_tag] Update Failed');

        Get.snackbar("Error", "Failed to update settings");
      }
    } catch (e, stackTrace) {
      print('[$_tag] Exception: $e');
      print('[$_tag] StackTrace: $stackTrace');

      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
      print('[$_tag] Update Complete');
    }
  }
}