import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum.dart';
import '../model/investment_request.dart';



class AddInvestmentController extends GetxController {

  /// Selected Investment Mode
  final selectedMode = InvestmentMode.cash.obs;

  /// Draft Model
  final request = InvestmentRequestModel().obs;

  /// Form Key
  final formKey = GlobalKey<FormState>();

  /// Doctor

  final doctorController = TextEditingController();

  /// Cash

  final amountController = TextEditingController();

  final purposeController = TextEditingController();

  /// NEFT

  final accountHolderController = TextEditingController();

  final accountNumberController = TextEditingController();

  final ifscController = TextEditingController();

  final bankController = TextEditingController();

  /// UPI

  final upiController = TextEditingController();

  /// Gift

  final itemController = TextEditingController();

  final quantityController =
  TextEditingController(text: "1");

  final itemValueController =
  TextEditingController();

  /// Dummy Doctors

  final doctors = <String>[

    "Dr. Meenakshi Rao",

    "Dr. Sharma",

    "Dr. Khan",

    "Dr. Tyagi",

    "Dr. Amit",

  ].obs;

  final selectedDoctor = RxnString();

  @override
  void onInit() {
    super.onInit();

    selectedDoctor.value = doctors.first;

    doctorController.text = doctors.first;
  }

  void changeMode(InvestmentMode mode) {

    selectedMode.value = mode;

    request.update((value) {

      value?.mode = mode;

    });

  }

  void selectDoctor(String? doctor) {

    if (doctor == null) return;

    selectedDoctor.value = doctor;

    doctorController.text = doctor;

    request.update((value) {

      value?.doctorName = doctor;

    });

  }

  void saveDraft() {

    Get.snackbar(

      "Saved",

      "Draft saved successfully.",

      snackPosition: SnackPosition.BOTTOM,

    );

  }

  void submit() {

    if (!formKey.currentState!.validate()) {
      return;
    }

    request.update((value) {

      value?.doctorName = selectedDoctor.value;

      value?.amount =
          double.tryParse(amountController.text) ?? 0;

      value?.purpose =
          purposeController.text;

      value?.accountHolder =
          accountHolderController.text;

      value?.accountNumber =
          accountNumberController.text;

      value?.ifsc =
          ifscController.text;

      value?.bankName =
          bankController.text;

      value?.upiId =
          upiController.text;

      value?.itemName =
          itemController.text;

      value?.quantity =
          int.tryParse(quantityController.text) ?? 1;

      value?.itemValue =
          double.tryParse(itemValueController.text) ?? 0;

    });

    Get.snackbar(

      "Success",

      "Investment Request Submitted",

      snackPosition: SnackPosition.BOTTOM,

    );

  }

  @override
  void onClose() {

    doctorController.dispose();

    amountController.dispose();

    purposeController.dispose();

    accountHolderController.dispose();

    accountNumberController.dispose();

    ifscController.dispose();

    bankController.dispose();

    upiController.dispose();

    itemController.dispose();

    quantityController.dispose();

    itemValueController.dispose();

    super.onClose();

  }

}