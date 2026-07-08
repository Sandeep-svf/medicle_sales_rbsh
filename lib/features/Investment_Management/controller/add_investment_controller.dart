import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../enum.dart';
import '../model/investment_request.dart';
import '../model/investment_request_model.dart';
import 'investment_request_controller.dart';

class AddInvestmentController extends GetxController {


  /// EMI Doctor Details

  final areaHQController = TextEditingController();

  final qualificationController = TextEditingController();

  final productSuggestedController = TextEditingController();

  final monthlyExpectedSalesController =
  TextEditingController();



  /// EMI Investment

  final emiAmountController = TextEditingController();

  final emiDateController = TextEditingController();

  final emiMonthsController = TextEditingController();

  final emiRemarksController = TextEditingController();


  /// EMI Bank Details

  final emiAccountNumberController =
  TextEditingController();

  final emiIfscController =
  TextEditingController();

  final emiAccountHolderController =
  TextEditingController();

  ///=========================================================
  /// FORM
  ///=========================================================

  final formKey = GlobalKey<FormState>();

  ///=========================================================
  /// LOADING
  ///=========================================================

  final RxBool isLoading = false.obs;

  ///=========================================================
  /// PAYMENT MODE
  ///=========================================================

  final selectedMode = InvestmentMode.cash.obs;

  ///=========================================================
  /// DOCTOR
  ///=========================================================

  /// Doctor Id will come from Doctor API screen later
  final selectedDoctorId = "".obs;

  final selectedDoctorName = "".obs;

  /// Optional Doctor Name (UI only)
  final doctorNameController = TextEditingController();

  ///=========================================================
  /// CASH / COMMON
  ///=========================================================

  final amountController = TextEditingController();

  final purposeController = TextEditingController();

  ///=========================================================
  /// NEFT
  ///=========================================================

  final accountHolderController = TextEditingController();

  final accountNumberController = TextEditingController();

  final ifscController = TextEditingController();

  final bankController = TextEditingController();

  ///=========================================================
  /// UPI
  ///=========================================================

  final upiController = TextEditingController();

  ///=========================================================
  /// GIFT
  ///=========================================================

  final justificationController = TextEditingController();

  final itemNameController = TextEditingController();

  final quantityController =
  TextEditingController(text: "1");

  final valueController =
  TextEditingController();

  final RxList<GiftItem> giftItems =
      <GiftItem>[].obs;

  ///=========================================================
  /// PAYMENT PROOF
  ///=========================================================

  /// Store Base64 String
  String? paymentProof;

  ///=========================================================
  /// AUTH
  ///=========================================================

  final AuthManager _authManager =
  AuthManager();

  ///=========================================================
  /// API
  ///=========================================================

  final String apiUrl =
      "${THttpHelper.baseUrl}/investment-requests";

  ///=========================================================
  /// CHANGE MODE
  ///=========================================================

  void changeMode(InvestmentMode mode) {
    selectedMode.value = mode;
  }

  ///=========================================================
  /// SET DOCTOR
  ///=========================================================

  void setDoctor({
    required String id,
    required String name,
  }) {
    selectedDoctorId.value = id;
    selectedDoctorName.value = name;
  }

  ///=========================================================
  /// PAYMENT PROOF
  ///=========================================================

  void setPaymentProof(String base64) {
    paymentProof = base64;
  }

  ///=========================================================
  /// GIFT ITEMS
  ///=========================================================

  void addGiftItem() {
    giftItems.add(

      GiftItem(

        itemName: itemNameController.text.trim(),

        quantity:
        int.tryParse(quantityController.text) ??
            1,

        value:
        double.tryParse(valueController.text) ??
            0,

      ),

    );

    itemNameController.clear();

    quantityController.text = "1";

    valueController.clear();
  }

  void removeGiftItem(int index) {
    giftItems.removeAt(index);
  }

  ///=========================================================
  /// CLEAR FORM
  ///=========================================================

  void clearForm() {
    amountController.clear();

    purposeController.clear();

    accountHolderController.clear();

    accountNumberController.clear();

    ifscController.clear();

    bankController.clear();

    upiController.clear();

    justificationController.clear();

    itemNameController.clear();

    quantityController.text = "1";

    valueController.clear();

    paymentProof = null;

    giftItems.clear();
  }

  @override
  void onClose() {
    doctorNameController.dispose();

    amountController.dispose();

    purposeController.dispose();

    accountHolderController.dispose();

    accountNumberController.dispose();

    ifscController.dispose();

    bankController.dispose();

    upiController.dispose();

    justificationController.dispose();

    itemNameController.dispose();

    quantityController.dispose();

    valueController.dispose();

    areaHQController.dispose();
    qualificationController.dispose();
    productSuggestedController.dispose();
    monthlyExpectedSalesController.dispose();

    emiAmountController.dispose();
    emiDateController.dispose();
    emiMonthsController.dispose();
    emiRemarksController.dispose();


    emiAccountNumberController.dispose();
    emiIfscController.dispose();
    emiAccountHolderController.dispose();

    super.onClose();
  }


  ///=========================================================
  /// SUBMIT REQUEST
  ///=========================================================

  Future<void> submitInvestment() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDoctorId.value.isEmpty) {
      Get.snackbar(
        "Doctor",
        "Please select doctor.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading(true);

      final token = await _authManager.getAuthToken();

      if (token == null || token.isEmpty) {
        Get.snackbar(
          "Authentication",
          "Token not found. Please login again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final InvestmentRequestModel request =
      _buildInvestmentRequest();

      final payload = request.toJson();

      debugPrint("");
      debugPrint(
          "============= INVESTMENT REQUEST =============");
      debugPrint("URL : $apiUrl");
      debugPrint("METHOD : POST");
      debugPrint("TOKEN : Bearer $token");
      debugPrint("PAYLOAD :");
      debugPrint(
        const JsonEncoder.withIndent("  ")
            .convert(payload),
      );
      debugPrint(
          "==============================================");

      final response = await http
          .post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      )
          .timeout(
        const Duration(seconds: 30),
      );

      debugPrint("");
      debugPrint(
          "============= INVESTMENT RESPONSE ============");
      debugPrint(
          "STATUS CODE : ${response.statusCode}");
      debugPrint("BODY :");
      debugPrint(response.body);
      debugPrint(
          "==============================================");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        Get.snackbar(
          "Success",
          "Investment Request Submitted",
          snackPosition: SnackPosition.BOTTOM,
        );

        clearForm();

        // Refresh investment list if it already exists
        if (Get.isRegistered<InvestmentRequestController>()) {
          Get.find<InvestmentRequestController>()
              .fetchInvestmentRequests(showLoader: false);
        }

        Get.back(); // Return to Investment List

        return;
      }

      String message = "Something went wrong.";

      try {
        final body = jsonDecode(response.body);

        if (body["message"] != null) {
          message = body["message"];
        }
      } catch (_) {}

      Get.snackbar(
        "Failed",
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on TimeoutException {
      Get.snackbar(
        "Timeout",
        "Server timeout.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stack) {
      debugPrint("Investment Exception");
      debugPrint(e.toString());
      debugPrint(stack.toString());

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }



  bool validateDoctor() {
    if (selectedDoctorId.value.isEmpty) {
      Get.snackbar(
        "Doctor",
        "Please select doctor.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  bool validateGiftItems() {
    if (selectedMode.value == InvestmentMode.gift &&
        giftItems.isEmpty) {
      Get.snackbar(
        "Gift Items",
        "Please add at least one gift item.",
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    return true;
  }

  ///=========================================================
  /// BUILD REQUEST MODEL
  ///=========================================================

  InvestmentRequestModel _buildInvestmentRequest() {
    final request = InvestmentRequestModel();

    request.doctorId = selectedDoctorId.value;

    request.mode = selectedMode.value;

    request.status = "Pending";

    switch (selectedMode.value) {
      case InvestmentMode.cash:
        request.amount =
            double.tryParse(amountController.text);

        request.purpose =
            purposeController.text.trim();
        break;

      case InvestmentMode.neft:
        request.amount =
            double.tryParse(amountController.text);

        request.purpose =
            purposeController.text.trim();

        request.accountHolder =
            accountHolderController.text.trim();

        request.accountNumber =
            accountNumberController.text.trim();

        request.ifsc =
            ifscController.text.trim();

        request.bankName =
            bankController.text.trim();

        request.paymentProof =
            paymentProof;

        break;

      case InvestmentMode.upi:
        request.amount =
            double.tryParse(amountController.text);

        request.purpose =
            purposeController.text.trim();

        request.upiId =
            upiController.text.trim();

        request.paymentProof =
            paymentProof;

        break;

      case InvestmentMode.gift:
        request.justification =
            justificationController.text.trim();

        request.items = giftItems;

        break;



      case InvestmentMode.emi:
      // Temporary mapping until backend supports EMI
        request.amount = double.tryParse(emiAmountController.text);

        request.purpose = emiRemarksController.text.trim();

        request.accountHolder =
            emiAccountHolderController.text.trim();

        request.accountNumber =
            emiAccountNumberController.text.trim();

        request.ifsc =
            emiIfscController.text.trim();

        break;

      case InvestmentMode.gift:
        request.justification =
            justificationController.text.trim();

        request.items = giftItems;
        break;
    }




    return request;
  }
}