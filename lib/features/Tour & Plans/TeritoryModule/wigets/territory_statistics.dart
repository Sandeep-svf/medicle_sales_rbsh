import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../controller/territory_controller.dart';

class TerritoryStatistics extends GetView<TerritoryController> {
  const TerritoryStatistics({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      return Row(

        children: [

          Expanded(
            child: _item(
              Icons.location_on,
              controller.totalAreas.toString(),
              "Areas",
            ),
          ),

          Expanded(
            child: _item(
              Icons.local_hospital,
              controller.totalDoctors.toString(),
              "Doctors",
            ),
          ),

          Expanded(
            child: _item(
              Icons.route,
              controller.totalBeats.toString(),
              "Beats",
            ),
          ),

        ],

      );

    });

  }

  Widget _item(
      IconData icon,
      String value,
      String title,
      ) {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 4),

      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),

      decoration: BoxDecoration(

        color: Colors.grey.shade100,

        borderRadius: BorderRadius.circular(16),

      ),

      child: Column(

        children: [

          Icon(
            icon,
            color: TColors.primary,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: TSizes.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              fontSize: TSizes.fontSizeSm,
            ),
          ),

        ],

      ),

    );

  }

}