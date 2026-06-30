import 'package:get/get.dart';

import '../controller/territory_controller.dart';

class TerritoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TerritoryController>(
          () => TerritoryController(),
    );
  }
}