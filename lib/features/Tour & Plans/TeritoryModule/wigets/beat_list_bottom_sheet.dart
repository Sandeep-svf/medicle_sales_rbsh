import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import 'beat_card.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class BeatListBottomSheet extends GetView<TerritoryController> {
  const BeatListBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TColors.white,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(26),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Column(
            children: [
              Container(
                width: TSizes.v55,
                height: TSizes.v5,
                decoration: BoxDecoration(
                  color: TColors.materialGrey400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: TSizes.v20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      TTexts.beatManagement,
                      style: TextStyle(
                        fontSize: TSizes.v20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "${controller.visibleBeats.length} Beats",
                  )
                ],
              ),
              const SizedBox(height: TSizes.v20),
              Expanded(
                child: Obx(() {
                  return ListView.separated(
                    itemCount: controller.visibleBeats.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: TSizes.v14),
                    itemBuilder: (_, index) {
                      return BeatCard(
                        beat: controller.visibleBeats[index],
                      );
                    },
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
