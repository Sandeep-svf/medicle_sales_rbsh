import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/territory_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class BeatLegend extends GetView<TerritoryController> {
  const BeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.beats.isEmpty) {
        return const SizedBox();
      }

      return Container(
        constraints: const BoxConstraints(maxWidth: TSizes.v220),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: TColors.black12,
              blurRadius: TSizes.v8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              TTexts.uiTextBeats,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: TSizes.v15,
              ),
            ),
            const SizedBox(height: TSizes.v8),
            ...controller.beats.map((beat) {
              final selected = controller.selectedBeat.value?.id == beat.id;

              return InkWell(
                onTap: () {
                  if (selected) {
                    controller.selectedBeat.value = null;
                  } else {
                    controller.selectBeat(beat);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? controller.beatColor(beat).withOpacity(.15)
                        : TColors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: TSizes.v18,
                        height: TSizes.v18,
                        decoration: BoxDecoration(
                          color: controller.beatColor(beat),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: TSizes.v10),
                      Expanded(
                        child: Text(
                          beat.beatName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
