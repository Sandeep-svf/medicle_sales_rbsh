import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/local_storage/auth_manager.dart';
import '../api_service.dart';
import '../enum.dart';
import '../model/investment_request.dart';
import '../model/investment_request_model.dart';

class AddInvestmentController extends GetxController {
  AddInvestmentController({this.initialRequest});

  static const int maxPaymentProofBytes = 5 * 1024 * 1024;

  final InvestmentRequest? initialRequest;

  final ImagePicker _imagePicker = ImagePicker();

  /// EMI Doctor Details

  final areaHQController = TextEditingController();

  final qualificationController = TextEditingController();

  final productSuggestedController = TextEditingController();

  final monthlyExpectedSalesController = TextEditingController();

  /// EMI Investment

  final emiAmountController = TextEditingController();

  final emiDateController = TextEditingController();

  final emiMonthsController = TextEditingController();

  final emiRemarksController = TextEditingController();

  /// EMI Bank Details

  final emiAccountNumberController = TextEditingController();

  final emiIfscController = TextEditingController();

  final emiAccountHolderController = TextEditingController();

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

  final quantityController = TextEditingController(text: "1");

  final valueController = TextEditingController();

  final RxList<GiftItem> giftItems = <GiftItem>[].obs;

  ///=========================================================
  /// OPTIONAL IMAGE (NEFT / UPI ONLY)
  ///=========================================================

  final Rxn<Uint8List> paymentProofBytes = Rxn<Uint8List>();

  final RxString paymentProofName = "".obs;

  final RxInt paymentProofSizeBytes = 0.obs;

  final RxBool isPickingPaymentProof = false.obs;

  final RxString existingPaymentProofUrl = "".obs;

  bool get hasPaymentProof => paymentProofBytes.value?.isNotEmpty == true;

  bool get supportsPaymentImage =>
      selectedMode.value == InvestmentMode.neft ||
      selectedMode.value == InvestmentMode.upi;

  bool get _shouldUseMultipart => supportsPaymentImage && hasPaymentProof;

  String get paymentProofSizeLabel {
    final bytes = paymentProofSizeBytes.value;

    if (bytes < 1024) {
      return "$bytes B";
    }

    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }

    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  ///=========================================================
  /// AUTH
  ///=========================================================

  final AuthManager _authManager = AuthManager();

  final InvestmentApiService _apiService = InvestmentApiService();

  ///=========================================================
  /// API
  ///=========================================================

  String? get editingRequestId {
    final id = initialRequest?.id?.trim();
    return id == null || id.isEmpty ? null : id;
  }

  bool get isEditing => editingRequestId != null;

  String get screenTitle =>
      isEditing ? "Edit Investment Request" : "New Investment Request";

  String get submitButtonLabel =>
      isEditing ? "Resubmit Request" : "Submit Request";

  bool get _isAndroidPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void onInit() {
    super.onInit();

    final request = initialRequest;
    if (request != null) {
      _populateForEditing(request);
    }

    if (_isAndroidPlatform) {
      unawaited(_recoverLostPaymentProof());
    }
  }

  ///=========================================================
  /// CHANGE MODE
  ///=========================================================

  void changeMode(InvestmentMode mode) {
    if (selectedMode.value != mode) {
      removePaymentProof();
    }

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

  void _populateForEditing(InvestmentRequest request) {
    final doctorId = request.doctorId?.trim();
    selectedDoctorId.value = doctorId?.isNotEmpty == true
        ? doctorId!
        : request.doctor?.id?.trim() ?? "";
    selectedDoctorName.value = request.displayDoctorName;
    selectedMode.value = _modeFromPaymentMode(request.paymentMode);
    amountController.text = _numberText(request.amount);
    purposeController.text = request.purpose?.trim() ?? "";
    upiController.text = request.upiId?.trim() ?? "";
    justificationController.text = request.justification?.trim() ?? "";
    existingPaymentProofUrl.value = request.paymentProof?.trim() ?? "";

    final bankDetails = request.bankDetails?.trim() ?? "";
    accountNumberController.text = _bankDetailValue(bankDetails, "A/C");
    ifscController.text = _bankDetailValue(bankDetails, "IFSC");
    bankController.text = _bankDetailValue(bankDetails, "Bank");
    accountHolderController.text = _bankDetailValue(bankDetails, "Beneficiary");

    giftItems.assignAll(
      request.items
          .where(
            (item) =>
                item.itemName?.trim().isNotEmpty == true &&
                (item.quantity ?? 0) > 0 &&
                (item.value ?? 0) > 0,
          )
          .map(
            (item) => GiftItem(
              itemName: item.itemName!.trim(),
              quantity: item.quantity!,
              value: item.value!,
            ),
          ),
    );
  }

  InvestmentMode _modeFromPaymentMode(String? paymentMode) {
    switch (paymentMode?.trim().toLowerCase()) {
      case "neft":
        return InvestmentMode.neft;
      case "upi":
        return InvestmentMode.upi;
      case "items/gift":
        return InvestmentMode.gift;
      case "cash":
      default:
        return InvestmentMode.cash;
    }
  }

  String _numberText(double? value) {
    if (value == null) {
      return "";
    }

    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String _bankDetailValue(String bankDetails, String label) {
    if (bankDetails.isEmpty) {
      return "";
    }

    final match = RegExp(
      "${RegExp.escape(label)}\\s*:\\s*(.*?)(?=,\\s*(?:A/C|IFSC|Bank|Beneficiary)\\s*:|\$)",
      caseSensitive: false,
    ).firstMatch(bankDetails);

    return match?.group(1)?.trim() ?? "";
  }

  ///=========================================================
  /// PAYMENT PROOF
  ///=========================================================

  Future<void> pickPaymentProofFromCamera() async {
    await _pickPaymentProof(ImageSource.camera);
  }

  Future<void> pickPaymentProofFromGallery() async {
    await _pickPaymentProof(ImageSource.gallery);
  }

  void removePaymentProof() {
    paymentProofBytes.value = null;
    paymentProofName.value = "";
    paymentProofSizeBytes.value = 0;
  }

  Future<void> _pickPaymentProof(ImageSource source) async {
    if (isLoading.value || isPickingPaymentProof.value) {
      return;
    }

    if (!supportsPaymentImage) {
      _showMediaMessage(
        "Image Upload",
        "Images can be attached only to NEFT and UPI requests.",
      );
      return;
    }

    if (!_isAndroidPlatform) {
      _showMediaMessage(
        "Payment Proof",
        "Image capture and upload are currently available on Android only.",
      );
      return;
    }

    isPickingPaymentProof(true);

    try {
      if (source == ImageSource.camera && !await _ensureCameraPermission()) {
        return;
      }

      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
        requestFullMetadata: false,
      );

      if (image == null) {
        return;
      }

      await _storePaymentProof(image);
    } on PlatformException catch (error) {
      debugPrint("Payment proof picker error: ${error.code}");
      _showMediaMessage(
        "Unable to Select Image",
        _pickerErrorMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint("Payment proof error: $error");
      debugPrintStack(stackTrace: stackTrace);
      _showMediaMessage(
        "Unable to Select Image",
        "The image could not be opened. Please try another image.",
      );
    } finally {
      isPickingPaymentProof(false);
    }
  }

  Future<void> _recoverLostPaymentProof() async {
    try {
      final lostData = await _imagePicker.retrieveLostData();

      if (lostData.isEmpty ||
          lostData.files == null ||
          lostData.files!.isEmpty) {
        return;
      }

      await _storePaymentProof(lostData.files!.first, showErrors: false);
    } catch (error) {
      debugPrint("Payment proof recovery error: $error");
    }
  }

  Future<bool> _ensureCameraPermission() async {
    final currentStatus = await Permission.camera.status;

    if (currentStatus.isGranted) {
      return true;
    }

    if (currentStatus.isPermanentlyDenied || currentStatus.isRestricted) {
      _showCameraSettingsDialog();
      return false;
    }

    final requestedStatus = await Permission.camera.request();

    if (requestedStatus.isGranted) {
      return true;
    }

    if (requestedStatus.isPermanentlyDenied || requestedStatus.isRestricted) {
      _showCameraSettingsDialog();
    } else {
      _showMediaMessage(
        "Camera Permission",
        "Camera permission is required to capture a payment proof.",
      );
    }

    return false;
  }

  Future<void> _storePaymentProof(
    XFile image, {
    bool showErrors = true,
  }) async {
    final fileSize = await image.length();

    if (fileSize <= 0) {
      if (showErrors) {
        _showMediaMessage(
          "Invalid Image",
          "The selected image is empty. Please choose another image.",
        );
      }
      return;
    }

    if (fileSize > maxPaymentProofBytes) {
      if (showErrors) {
        _showMediaMessage(
          "Image Too Large",
          "Please select an image smaller than 5 MB.",
        );
      }
      return;
    }

    final bytes = await image.readAsBytes();

    if (bytes.isEmpty || bytes.lengthInBytes > maxPaymentProofBytes) {
      if (showErrors) {
        _showMediaMessage(
          "Invalid Image",
          "Please select a valid image smaller than 5 MB.",
        );
      }
      return;
    }

    paymentProofBytes.value = bytes;
    paymentProofName.value =
        image.name.trim().isEmpty ? "payment_proof.jpg" : image.name.trim();
    paymentProofSizeBytes.value = bytes.lengthInBytes;
  }

  void _showCameraSettingsDialog() {
    if (Get.isDialogOpen == true) {
      return;
    }

    Get.defaultDialog<void>(
      title: "Camera Permission",
      middleText:
          "Camera access is disabled. Enable it in app settings to capture a payment proof.",
      textCancel: "Not Now",
      textConfirm: "Open Settings",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        unawaited(_openAppSettingsSafely());
      },
    );
  }

  Future<void> _openAppSettingsSafely() async {
    try {
      final opened = await openAppSettings();

      if (!opened) {
        _showMediaMessage(
          "App Settings",
          "Could not open app settings. Please open them manually.",
        );
      }
    } catch (error) {
      debugPrint("Open app settings error: $error");
      _showMediaMessage(
        "App Settings",
        "Could not open app settings. Please open them manually.",
      );
    }
  }

  String _pickerErrorMessage(PlatformException error) {
    switch (error.code) {
      case "camera_access_denied":
        return "Camera permission is required to capture a payment proof.";
      case "camera_access_restricted":
        return "Camera access is restricted on this device.";
      case "photo_access_denied":
        return "Photo access was denied. Please choose the image again.";
      case "no_available_camera":
        return "No camera is available on this device.";
      case "already_active":
      case "multiple_request":
        return "Another image selection is already open.";
      default:
        return "The image could not be opened. Please try again.";
    }
  }

  void _showMediaMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  ///=========================================================
  /// GIFT ITEMS
  ///=========================================================

  void addGiftItem() {
    final itemName = itemNameController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim());
    final value = double.tryParse(valueController.text.trim());

    if (itemName.isEmpty ||
        quantity == null ||
        quantity <= 0 ||
        value == null ||
        value <= 0) {
      Get.snackbar(
        "Gift Item",
        "Enter an item name, positive quantity, and positive value.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    giftItems.add(
      GiftItem(
        itemName: itemName,
        quantity: quantity,
        value: value,
      ),
    );

    itemNameController.clear();

    quantityController.text = "1";

    valueController.clear();
  }

  void removeGiftItem(int index) {
    giftItems.removeAt(index);
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }

    return null;
  }

  String? validateAmount(String? value) {
    final requiredMessage = validateRequired(value, "Amount");
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final amount = double.tryParse(value!.trim());
    if (amount == null || amount <= 0) {
      return "Enter a valid amount greater than zero";
    }

    return null;
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

    removePaymentProof();

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
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!validateDoctor()) {
      return;
    }

    if (selectedMode.value == InvestmentMode.emi) {
      Get.snackbar(
        "Unsupported Mode",
        "EMI is not supported by the Investment Request API.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!validateGiftItems()) {
      return;
    }

    if (isEditing && initialRequest?.canEdit != true) {
      Get.snackbar(
        "Edit Not Available",
        "Only Draft or Rejected requests can be edited.",
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

      final request = _buildInvestmentRequest(status: "Pending");
      final payload = request.toJson();
      final proofBytes = _shouldUseMultipart ? paymentProofBytes.value : null;
      final requestId = editingRequestId;
      final requestUrl = requestId == null
          ? InvestmentApiService.requestsUrl
          : InvestmentApiService.requestUrl(requestId);

      debugPrint("");
      debugPrint("============= INVESTMENT REQUEST =============");
      debugPrint("URL : $requestUrl");
      debugPrint("METHOD : ${requestId == null ? "POST" : "PUT"}");
      debugPrint("TOKEN : Bearer [redacted]");
      debugPrint(
        "CONTENT TYPE : ${proofBytes == null ? "application/json" : "multipart/form-data"}",
      );
      debugPrint("PAYLOAD :");
      debugPrint(const JsonEncoder.withIndent("  ").convert(payload));

      if (proofBytes != null) {
        debugPrint(
          "FILE : paymentProof -> ${paymentProofName.value} ($paymentProofSizeLabel)",
        );
      }

      debugPrint("==============================================");

      final response = requestId == null
          ? await _apiService.createRequest(
              token: token,
              payload: payload,
              paymentProofBytes: proofBytes,
              paymentProofFilename:
                  proofBytes == null ? null : paymentProofName.value,
            )
          : await _apiService.updateRequest(
              token: token,
              id: requestId,
              payload: payload,
              paymentProofBytes: proofBytes,
              paymentProofFilename:
                  proofBytes == null ? null : paymentProofName.value,
            );

      debugPrint("");
      debugPrint("============= INVESTMENT RESPONSE ============");
      debugPrint("STATUS CODE : ${response.statusCode}");
      debugPrint("BODY :");
      debugPrint(response.body);
      debugPrint("==============================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final successMessage = _apiService.responseMessage(
          response,
          fallback: requestId == null
              ? "Investment request submitted successfully."
              : "Investment request updated and submitted successfully.",
        );

        Get.back(result: successMessage, closeOverlays: true);
        return;
      }

      Get.snackbar(
        "Failed",
        _apiService.responseMessage(
          response,
          fallback: "Request failed (HTTP ${response.statusCode}).",
        ),
        snackPosition: SnackPosition.BOTTOM,
      );
    } on TimeoutException {
      Get.snackbar(
        "Timeout",
        "Server timeout.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error, stackTrace) {
      debugPrint("Investment Exception: $error");
      debugPrintStack(stackTrace: stackTrace);

      Get.snackbar(
        "Error",
        "Unable to submit the investment request. Please try again.",
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
    if (selectedMode.value == InvestmentMode.gift && giftItems.isEmpty) {
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

  InvestmentRequestModel _buildInvestmentRequest({required String status}) {
    final request = InvestmentRequestModel();

    request.doctorId = selectedDoctorId.value;

    request.mode = selectedMode.value;

    request.status = status;

    switch (selectedMode.value) {
      case InvestmentMode.cash:
        request.amount = double.tryParse(amountController.text);

        request.purpose = purposeController.text.trim();
        break;

      case InvestmentMode.neft:
        request.amount = double.tryParse(amountController.text);

        request.purpose = purposeController.text.trim();

        request.accountHolder = accountHolderController.text.trim();

        request.accountNumber = accountNumberController.text.trim();

        request.ifsc = ifscController.text.trim();

        request.bankName = bankController.text.trim();

        break;

      case InvestmentMode.upi:
        request.amount = double.tryParse(amountController.text);

        request.purpose = purposeController.text.trim();

        request.upiId = upiController.text.trim();

        break;

      case InvestmentMode.gift:
        request.justification = justificationController.text.trim();

        request.items = giftItems;

        break;

      case InvestmentMode.emi:
        // Temporary mapping until backend supports EMI
        request.amount = double.tryParse(emiAmountController.text);

        request.purpose = emiRemarksController.text.trim();

        request.accountHolder = emiAccountHolderController.text.trim();

        request.accountNumber = emiAccountNumberController.text.trim();

        request.ifsc = emiIfscController.text.trim();

        break;
    }

    return request;
  }
}
