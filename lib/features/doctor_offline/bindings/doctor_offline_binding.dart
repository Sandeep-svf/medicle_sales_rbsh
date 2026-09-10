import 'package:get/get.dart';

import '../controllers/doctor_offline_controller.dart';

class DoctorOfflineBinding extends Bindings {
  DoctorOfflineBinding({required this.controller, required this.tag});

  final DoctorOfflineController controller;
  final String tag;

  @override
  void dependencies() {
    if (!Get.isRegistered<DoctorOfflineController>(tag: tag)) {
      Get.put<DoctorOfflineController>(controller, tag: tag);
    }
  }
}
