import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/TeritoryModule/wigets/territory_layer_chips.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/TeritoryModule/wigets/territory_quick_actions.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/TeritoryModule/wigets/territory_statistics.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class TerritoryBottomPanel extends GetView<TerritoryController> {
  const TerritoryBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: TSizes.v12,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: const BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
            top: false,
            child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Expand / Collapse
                    InkWell(
                      onTap: () => controller.showTools.toggle(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.showTools.value
                                ? "Hide Details"
                                : "Show Details",
                          ),
                          Icon(
                            controller.showTools.value
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                          ),
                        ],
                      ),
                    ),

                    /// Hidden widgets
                    Obx(
                      () => AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: controller.showTools.value
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          children: const [
                            TerritoryStatistics(),
                            SizedBox(height: TSizes.v18),
                            TerritoryLayerChips(),
                            SizedBox(height: TSizes.v18),
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),
                    ),

                    /// Always visible
                    const TerritoryQuickActions(),
                  ],
                ))),
      ),
    );
  }
}
