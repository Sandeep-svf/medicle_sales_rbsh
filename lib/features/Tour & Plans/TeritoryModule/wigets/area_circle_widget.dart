import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../model/area_model.dart';
import 'beat_area_avatar.dart';

class AreaCircleWidget extends GetView<TerritoryController> {

  final AreaModel area;

  const AreaCircleWidget({
    super.key,
    required this.area,
  });

  @override
  @override
  Widget build(BuildContext context) {

    return Obx(() {

      final selected = controller.isAreaSelected(area.id);

      return GestureDetector(

        onTap: () {
          controller.showAreaActions(area);
        },

      child: AnimatedContainer(

        duration: const Duration(
          milliseconds: 250,
        ),

        width: 100,

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),

        decoration: BoxDecoration(

          color: selected
              ? TColors.primary
              : Colors.white,

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(

            color: selected
                ? TColors.primary
                : Colors.blue,

          ),

          boxShadow: const [

            BoxShadow(

              color: Colors.black12,

              blurRadius: 8,

            )

          ],

        ),

    child: SizedBox(
    height: 90,
    child: FittedBox(
    fit: BoxFit.scaleDown,
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      BeatAreaAvatar(
        colors: controller.selectedBeat.value == null
            ? controller.colorsForArea(area.id)
            : [
          if (controller.selectedBeatColorForArea(area.id) != null)
            controller.selectedBeatColorForArea(area.id)!,
        ],
        doctorCount: area.doctorCount,
      ),



            const SizedBox(height: 6),

            Text(

              area.postOffice,

              textAlign: TextAlign.center,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(

                fontWeight: FontWeight.bold,

                fontSize:
                TSizes.fontSizeSm,

                color: selected
                    ? Colors.white
                    : Colors.black,

              ),

            ),

            const SizedBox(height: 4),
      Text(
        controller.beatNamesForArea(area.id).isEmpty
            ? "No Beat"
            : controller.beatNamesForArea(area.id),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: selected
              ? Colors.white70
              : Colors.grey.shade700,
        ),
      ),



          ],

        ),

      ),
          ),
      ),
      );

    });

  }

}