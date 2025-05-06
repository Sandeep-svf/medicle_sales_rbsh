import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../utils/local_storage/auth_manager.dart';
import '../model/Stokist.dart';

class StokistListController extends GetxController {
  var isLoading = false.obs;
  var StokistList = <Stokist>[].obs;
  AuthManager authManager = AuthManager();
  late String headOffice = "";

  @override
  void onInit() {
    fetchStokist();
    super.onInit();
  }

  void fetchStokist() async {
    print("[StokistListController] Fetching stockist list...");
    isLoading.value = true;
    headOffice = (await authManager.getHeadOffice())!;

    final url = Uri.parse("https://medi-glucks-erp.onrender.com/api/stockists/by-head-office/$headOffice");

    try {
      final response = await http.get(url);
      print("[HTTP] Response Status: ${response.statusCode}");
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {

        final List<dynamic> data = jsonData['data'] ?? [];



        print("[HTTP] JSON Data Length: ${data.length}");

        StokistList.value = data.map((item) {
          final stokist = Stokist.fromJson(item);
          print("[Parsed] Stokist: ${stokist.firmName}");
          return stokist;
        }).toList();

        print("[StokistListController] Successfully fetched and parsed ${StokistList.length} stockists.");
      } else {
        print("[Error] Failed to fetch stockists: ${response.statusCode}");
        Get.snackbar(
          "Error",
          "Failed to fetch stockists: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("[Exception] Error during fetch: $e");
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      print("[StokistListController] Fetch process complete. isLoading = false");
    }
  }


  /*void fetchStokist() async {
    isLoading.value = true;
    final url = Uri.parse("https://medi-glucks-erp.onrender.com/api/stockists");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        StokistList.value = data.map((item) => Stokist.fromJson(item)).toList();
      } else {
        Get.snackbar("Error", "Failed to fetch stockists: ${response.statusCode}", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }*/

  void addClinic(Stokist clinic) {
    StokistList.add(clinic);
  }
}
