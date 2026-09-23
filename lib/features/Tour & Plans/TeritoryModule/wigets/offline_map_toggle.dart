import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controller/territory_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class OfflineMapToggle extends GetView<TerritoryController> {
  const OfflineMapToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: TColors.black12,
              blurRadius: TSizes.v8,
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.toggleOfflineMode(false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.isOfflineMode.value
                        ? TColors.transparent
                        : TColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    TTexts.uiTextOnline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: controller.isOfflineMode.value
                          ? TColors.pureBlack
                          : TColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.toggleOfflineMode(true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.isOfflineMode.value
                        ? TColors.primary
                        : TColors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    TTexts.uiTextOffline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: controller.isOfflineMode.value
                          ? TColors.white
                          : TColors.pureBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
