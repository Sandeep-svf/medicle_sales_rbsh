import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../model/investment_request_model.dart';



class InvestmentRequestController extends GetxController {

  /// View Mode
  final RxBool tableView = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final AuthManager _authManager = AuthManager();

  void toggleView(bool value) {
    tableView.value = value;
  }

  final RxList<InvestmentRequest> investmentRequests =
      <InvestmentRequest>[].obs;

  final RxInt totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvestmentRequests();
  }

  Future<void> fetchInvestmentRequests({
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      final token = await _authManager.getAuthToken();

      debugPrint(
        "InvestmentRequestController -> Token : ${token ?? 'NULL'}",
      );

      final response = await http.get(
        Uri.parse(
          "${THttpHelper.baseUrl}/investment-requests",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint(
        "InvestmentRequestController -> Status Code : ${response.statusCode}",
      );

      debugPrint(
        "InvestmentRequestController -> Response : ${response.body}",
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
        jsonDecode(response.body);

        final result =
        InvestmentRequestResponse.fromJson(json);

        if (result.success) {
          investmentRequests.assignAll(result.data);
          totalCount.value = result.count;

          debugPrint(
            "InvestmentRequestController -> Loaded ${result.count} Requests",
          );
        } else {
          investmentRequests.clear();
          totalCount.value = 0;
          errorMessage.value = "No Investment Requests Found";

          debugPrint(
            "InvestmentRequestController -> API returned success=false",
          );
        }
      } else {
        investmentRequests.clear();
        totalCount.value = 0;
        errorMessage.value =
        "HTTP ${response.statusCode}";

        debugPrint(
          "InvestmentRequestController -> HTTP Error ${response.statusCode}",
        );

        debugPrint(
          "InvestmentRequestController -> ${response.body}",
        );
      }
    } catch (e, stackTrace) {
      investmentRequests.clear();
      totalCount.value = 0;
      errorMessage.value = e.toString();

      debugPrint(
        "InvestmentRequestController -> Exception : $e",
      );

      debugPrint(
        "InvestmentRequestController -> StackTrace : $stackTrace",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchInvestmentRequests(showLoader: false);
  }

  void clearData() {
    investmentRequests.clear();
    totalCount.value = 0;
    errorMessage.value = '';
  }

  InvestmentRequest? findById(String id) {
    try {
      return investmentRequests.firstWhere(
            (e) => e.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  List<InvestmentRequest> filterByPaymentMode(String mode) {
    return investmentRequests
        .where((e) => e.paymentMode == mode)
        .toList();
  }

  List<InvestmentRequest> filterByStatus(String status) {
    return investmentRequests
        .where((e) => e.status == status)
        .toList();
  }

  List<InvestmentRequest> get pendingRequests =>
      investmentRequests
          .where((e) => e.status == "Pending")
          .toList();

  List<InvestmentRequest> get draftRequests =>
      investmentRequests
          .where((e) => e.status == "Draft")
          .toList();

  List<InvestmentRequest> get cashRequests =>
      investmentRequests
          .where((e) => e.paymentMode == "Cash")
          .toList();

  List<InvestmentRequest> get neftRequests =>
      investmentRequests
          .where((e) => e.paymentMode == "NEFT")
          .toList();

  List<InvestmentRequest> get upiRequests =>
      investmentRequests
          .where((e) => e.paymentMode == "UPI")
          .toList();

  List<InvestmentRequest> get itemGiftRequests =>
      investmentRequests
          .where((e) => e.paymentMode == "Items/Gift")
          .toList();
}