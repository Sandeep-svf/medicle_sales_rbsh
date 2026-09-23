import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
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
          width: TSizes.v100,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected ? TColors.primary : TColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? TColors.primary : TColors.materialBlue,
            ),
            boxShadow: const [
              BoxShadow(
                color: TColors.black12,
                blurRadius: TSizes.v8,
              )
            ],
          ),
          child: SizedBox(
            height: TSizes.v90,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BeatAreaAvatar(
                    colors: controller.selectedBeat.value == null
                        ? controller.colorsForArea(area.id)
                        : [
                            if (controller.selectedBeatColorForArea(area.id) !=
                                null)
                              controller.selectedBeatColorForArea(area.id)!,
                          ],
                    doctorCount: area.doctorCount,
                  ),
                  const SizedBox(height: TSizes.v6),
                  Text(
                    area.postOffice,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: TSizes.fontSizeSm,
                      color: selected ? TColors.white : TColors.pureBlack,
                    ),
                  ),
                  const SizedBox(height: TSizes.v4),
                  Text(
                    controller.beatNamesForArea(area.id).isEmpty
                        ? "No Beat"
                        : controller.beatNamesForArea(area.id),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: TSizes.v10,
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? TColors.white70 : TColors.materialGrey700,
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
