import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/territory_controller.dart';
import '../utils/enumsclass.dart';


class TerritoryLayerChips extends GetView<TerritoryController> {
  const TerritoryLayerChips({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      return Wrap(

        spacing: 10,

        children: [

          FilterChip(

            label: const Text("Areas"),

            selected: controller.showAreas.value,

            onSelected: (_) {
              controller.toggleLayer(
                TerritoryLayer.area,
              );
            },

          ),

          FilterChip(

            label: const Text("Doctors"),

            selected: controller.showDoctors.value,

            onSelected: (_) {
              controller.toggleLayer(
                TerritoryLayer.doctor,
              );
            },

          ),

          FilterChip(

            label: const Text("Beats"),

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