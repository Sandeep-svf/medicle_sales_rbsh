// controllers/invoice_controller.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../model/InvoiceResponse.dart';


class InvoiceController extends GetxController {
  final String baseUrl;
  final String bearerToken;
  final Dio _dio = Dio();

  InvoiceController({
    required this.baseUrl,
    required this.bearerToken,
  });

  var invoices = <Invoice>[].obs;
  var loading = false.obs;
  var error = ''.obs;

  Future<void> fetchInvoices({int page = 1}) async {
    loading.value = true;
    error.value = '';
    try {

      AuthManager authManager = AuthManager();
      final barrierToken2 = await authManager.getAuthToken();

      final response = await _dio.get(
        '${THttpHelper.baseUrl}/invoice-tracking',
        queryParameters: {'page': page},
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $barrierToken2',
            HttpHeaders.acceptHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = InvoiceResponse.fromJson(response.data as Map<String, dynamic>);
        invoices.assignAll(parsed.data);
      } else {
        error.value = 'Unexpected response: ${response.statusCode}';
      }
    } on DioException catch (e) {
      error.value = e.message ?? 'Network error';
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
