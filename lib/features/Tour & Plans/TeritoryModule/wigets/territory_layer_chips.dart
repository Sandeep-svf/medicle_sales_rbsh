import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/territory_controller.dart';
import '../utils/enumsclass.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class TerritoryLayerChips extends GetView<TerritoryController> {
  const TerritoryLayerChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Wrap(
        spacing: TSizes.v10,
        children: [
          FilterChip(
            label: const Text(TTexts.uiTextAreas),
            selected: controller.showAreas.value,
            onSelected: (_) {
              controller.toggleLayer(
                TerritoryLayer.area,
              );
            },
          ),
          FilterChip(
            label: const Text(TTexts.uiTextDoctors),
            selected: controller.showDoctors.value,
            onSelected: (_) {
              controller.toggleLayer(
                TerritoryLayer.doctor,
              );
            },
          ),
          FilterChip(
            label: const Text(TTexts.uiTextBeats),
            selected: controller.showBeats.value,
            onSelected: (_) {
              controller.toggleLayer(
                TerritoryLayer.beat,
              );
            },
          ),
        ],
      );
    });
  }
}
