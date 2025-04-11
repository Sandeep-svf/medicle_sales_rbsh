import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../model/Clinic.dart';

class ClinicListController extends GetxController {
  var isLoading = false.obs;
  var clinicList = <Clinic>[].obs;

  @override
  void onInit() {
    fetchClinics();
    super.onInit();
  }

  void fetchClinics() {
    isLoading.value = true;
    clinicList.value = [
      Clinic(
        name: "Sunrise Clinic",
        address: "123 Main St",
        city: "New Delhi",
        phone: "9876543210",
        email: "info@sunriseclinic.com",
        latitude: 28.6139,
        longitude: 77.2090,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
    ];
    isLoading.value = false;
  }

  void addClinic(Clinic clinic) {
    clinicList.add(clinic);
  }
}