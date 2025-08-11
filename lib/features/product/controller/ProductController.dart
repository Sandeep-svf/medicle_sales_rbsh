import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import '../model/ProductModel.dart';

class ProductController extends GetxController {
  var isLoading = false.obs;
  var productList = <ProductModel>[].obs;
   String baseUrl = THttpHelper.baseUrl;

  final String apiUrl = "${THttpHelper.baseUrl}/products";
  final String logPrefix = "[ProductController]";

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      debugPrint('$logPrefix Fetching products from: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));
      debugPrint('$logPrefix Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('$logPrefix Products fetched: ${data.length} item(s)');

        productList.value = data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        debugPrint('$logPrefix Failed to load products: ${response.body}');
        Get.snackbar('Error', 'Failed to load products');
      }
    } catch (e) {
      debugPrint('$logPrefix Exception: $e');
      Get.snackbar('Exception', e.toString());
    } finally {
      isLoading.value = false;
      debugPrint('$logPrefix Loading complete');
    }
  }
}
