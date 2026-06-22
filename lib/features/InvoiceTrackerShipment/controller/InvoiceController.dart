// controllers/invoice_controller.dart
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../model/InvoiceResponse.dart';


class InvoiceController extends GetxController {
  final String baseUrl;
  final String bearerToken;
  final dio.Dio _dio = dio.Dio();

  InvoiceController({
    required this.baseUrl,
    required this.bearerToken,
  });

  var invoices = <Invoice>[].obs;
  var loading = false.obs;
  var error = ''.obs;

  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalCount = 0.obs;

  var isLoadingMore = false.obs;


  Future<void> sendInvoiceEmail(
      String invoiceId,
      ) async {

    final auth = AuthManager();
    final token = await auth.getAuthToken();

    await _dio.post(
      '${THttpHelper.baseUrl}/invoice-tracking/$invoiceId/send-email',
      options: dio.Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }


  Future<void> sendCustomEmail({
    required String invoiceId,
    required String subject,
    required String body,
    required List<File> attachments,
  }) async {

    final auth = AuthManager();
    final token = await auth.getAuthToken();

    final formData = dio.FormData.fromMap({
      "subject": subject,
      "body": body,
      "attachments": attachments
          .map(
            (file) => dio.MultipartFile.fromFileSync(
          file.path,
        ),
      )
          .toList(),
    });

    await _dio.post(
      '${THttpHelper.baseUrl}/invoice-tracking/$invoiceId/send-custom-email',
      data: formData,
      options: dio.Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }


  Future<void> fetchInvoices({
    int page = 1,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        loading.value = true;
        error.value = '';
      }

      AuthManager authManager = AuthManager();
      final token = await authManager.getAuthToken();

      final response = await _dio.get(
        '${THttpHelper.baseUrl}/invoice-tracking',
        queryParameters: {'page': page},
        options: dio.Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            HttpHeaders.acceptHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final parsed = InvoiceResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        currentPage.value =
            parsed.pagination?.currentPage ?? page;

        totalPages.value =
            parsed.pagination?.totalPages ?? 1;

        totalCount.value =
            parsed.pagination?.totalCount ?? 0;

        if (loadMore) {
          invoices.addAll(parsed.data);
        } else {
          invoices.assignAll(parsed.data);
        }
      }
    } on dio.DioException catch (e) {
      error.value = e.message ?? 'Network error';
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
      isLoadingMore.value = false;
    }
  }


  Future<void> loadMoreInvoices() async {
    if (isLoadingMore.value) return;

    if (currentPage.value >= totalPages.value) return;

    await fetchInvoices(
      page: currentPage.value + 1,
      loadMore: true,
    );
  }

/*  Future<void> fetchInvoices({int page = 1}) async {
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
  }*/
}
