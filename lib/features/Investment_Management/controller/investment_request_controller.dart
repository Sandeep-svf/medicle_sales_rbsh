import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/local_storage/auth_manager.dart';
import '../api_service.dart';
import '../model/investment_request_model.dart';

class InvestmentRequestController extends GetxController {
  final RxBool tableView = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = "".obs;
  final RxList<InvestmentRequest> investmentRequests =
      <InvestmentRequest>[].obs;
  final RxInt totalCount = 0.obs;
  final RxSet<String> processingRequestIds = <String>{}.obs;

  final AuthManager _authManager = AuthManager();
  final InvestmentApiService _apiService = InvestmentApiService();

  String? _lastStatus;
  bool _lastByHeadOffice = false;

  @override
  void onInit() {
    super.onInit();
    fetchInvestmentRequests();
  }

  void toggleView(bool value) {
    tableView.value = value;
  }

  Future<void> fetchInvestmentRequests({
    bool showLoader = true,
    String? status,
    bool byHeadOffice = false,
  }) async {
    _lastStatus = status;
    _lastByHeadOffice = byHeadOffice;

    try {
      if (showLoader) {
        isLoading.value = true;
      }

      errorMessage.value = "";

      final token = await _authManager.getAuthToken();
      if (token == null || token.isEmpty) {
        _clearWithError("Authentication token not found. Please login again.");
        return;
      }

      final response = await _apiService.fetchRequests(
        token: token,
        status: status,
        byHeadOffice: byHeadOffice,
      );

      debugPrint(
        "Investment requests GET ${byHeadOffice ? InvestmentApiService.headOfficeRequestsUrl : InvestmentApiService.requestsUrl} -> ${response.statusCode}",
      );

      if (response.statusCode != 200) {
        _clearWithError(
          _apiService.responseMessage(
            response,
            fallback: "Unable to load requests (HTTP ${response.statusCode}).",
          ),
        );
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        _clearWithError("Invalid investment response received.");
        return;
      }

      final result = InvestmentRequestResponse.fromJson(
        Map<String, dynamic>.from(decoded),
      );

      if (!result.success) {
        _clearWithError(
          _apiService.responseMessage(
            response,
            fallback: "No investment requests found.",
          ),
        );
        return;
      }

      investmentRequests.assignAll(result.data);
      totalCount.value = result.count;
    } on TimeoutException {
      _clearWithError("Server timeout while loading investment requests.");
    } catch (error, stackTrace) {
      debugPrint("Investment list exception: $error");
      debugPrintStack(stackTrace: stackTrace);
      _clearWithError("Unable to load investment requests.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchByHeadOffice({
    bool showLoader = true,
    String? status,
  }) {
    return fetchInvestmentRequests(
      showLoader: showLoader,
      status: status,
      byHeadOffice: true,
    );
  }

  Future<bool> updateInvestmentRequest({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return _runMutation(
      id: id,
      request: (token) => _apiService.updateRequest(
        token: token,
        id: id,
        payload: payload,
      ),
      successFallback: "Investment request updated successfully.",
    );
  }

  Future<bool> approveInvestmentRequest(String id) {
    return _runMutation(
      id: id,
      request: (token) => _apiService.approveRequest(token: token, id: id),
      successFallback: "Investment request approved successfully.",
    );
  }

  Future<bool> rejectInvestmentRequest({
    required String id,
    required String rejectionReason,
  }) async {
    if (rejectionReason.trim().isEmpty) {
      Get.snackbar(
        "Rejection Reason",
        "Please enter a rejection reason.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return _runMutation(
      id: id,
      request: (token) => _apiService.rejectRequest(
        token: token,
        id: id,
        rejectionReason: rejectionReason,
      ),
      successFallback: "Investment request rejected successfully.",
    );
  }

  Future<bool> _runMutation({
    required String id,
    required Future<http.Response> Function(String token) request,
    required String successFallback,
  }) async {
    if (id.trim().isEmpty || processingRequestIds.contains(id)) {
      return false;
    }

    processingRequestIds.add(id);

    try {
      final token = await _authManager.getAuthToken();
      if (token == null || token.isEmpty) {
        Get.snackbar(
          "Authentication",
          "Token not found. Please login again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final response = await request(token);

      if (response.statusCode != 200) {
        Get.snackbar(
          "Failed",
          _apiService.responseMessage(
            response,
            fallback: "Request failed (HTTP ${response.statusCode}).",
          ),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      Get.snackbar(
        "Success",
        _apiService.responseMessage(response, fallback: successFallback),
        snackPosition: SnackPosition.BOTTOM,
      );

      await fetchInvestmentRequests(
        showLoader: false,
        status: _lastStatus,
        byHeadOffice: _lastByHeadOffice,
      );
      return true;
    } on TimeoutException {
      Get.snackbar(
        "Timeout",
        "Server timeout.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint("Investment mutation exception: $error");
      debugPrintStack(stackTrace: stackTrace);
      Get.snackbar(
        "Error",
        "Unable to update the investment request.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      processingRequestIds.remove(id);
    }
  }

  Future<void> refreshData() {
    return fetchInvestmentRequests(
      showLoader: false,
      status: _lastStatus,
      byHeadOffice: _lastByHeadOffice,
    );
  }

  void clearData() {
    investmentRequests.clear();
    totalCount.value = 0;
    errorMessage.value = "";
  }

  void _clearWithError(String message) {
    investmentRequests.clear();
    totalCount.value = 0;
    errorMessage.value = message;
  }

  InvestmentRequest? findById(String id) {
    try {
      return investmentRequests.firstWhere((request) => request.id == id);
    } catch (_) {
      return null;
    }
  }

  List<InvestmentRequest> filterByPaymentMode(String mode) {
    return investmentRequests
        .where((request) => request.paymentMode == mode)
        .toList();
  }

  List<InvestmentRequest> filterByStatus(String status) {
    return investmentRequests
        .where((request) => request.status == status)
        .toList();
  }

  List<InvestmentRequest> get pendingRequests => filterByStatus("Pending");

  List<InvestmentRequest> get draftRequests => filterByStatus("Draft");

  List<InvestmentRequest> get cashRequests => filterByPaymentMode("Cash");

  List<InvestmentRequest> get neftRequests => filterByPaymentMode("NEFT");

  List<InvestmentRequest> get upiRequests => filterByPaymentMode("UPI");

  List<InvestmentRequest> get itemGiftRequests =>
      filterByPaymentMode("Items/Gift");
}
