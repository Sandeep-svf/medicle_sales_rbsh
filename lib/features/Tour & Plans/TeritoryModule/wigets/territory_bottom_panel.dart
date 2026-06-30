import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/TeritoryModule/wigets/territory_layer_chips.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/TeritoryModule/wigets/territory_quick_actions.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/TeritoryModule/wigets/territory_statistics.dart';


import '../../../../utils/constants/sizes.dart';
import '../controller/territory_controller.dart';


class TerritoryBottomPanel extends GetView<TerritoryController> {
  const TerritoryBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [

              /// Handle
              SizedBox(
                width: 55,
                child: Divider(
                  thickness: 5,
                ),
              ),

              SizedBox(height: 14),

              TerritoryStatistics(),

              SizedBox(height: 18),

              TerritoryLayerChips(),

              SizedBox(height: 18),

              TerritoryQuickActions(),

            ],
          ),
        ),
      ),
    );
  }
}