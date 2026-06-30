import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../controller/territory_controller.dart';
import 'beat_list_bottom_sheet.dart';
import 'create_beat_bottom_sheet.dart';

class TerritoryQuickActions extends GetView<TerritoryController> {
  const TerritoryQuickActions({super.key});

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        Expanded(

          child: OutlinedButton.icon(

            onPressed: () {

              controller.startBeatCreation();

              Get.bottomSheet(

                const CreateBeatBottomSheet(),

                isScrollControlled: true,

                backgroundColor: Colors.transparent,

              );

            },
            icon: const Icon(Icons.add),

            label: const Text("New Beat"),

          ),

        ),

        const SizedBox(width: 12),

        Expanded(

          child: ElevatedButton.icon(

            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
            ),

            onPressed: () {

              Get.bottomSheet(

                const BeatListBottomSheet(),

                isScrollControlled: true,

                backgroundColor: Colors.transparent,

              );

            },

            icon: const Icon(Icons.route),

            label: const Text("Beats"),

          ),

        ),

      ],

    );

  }

}