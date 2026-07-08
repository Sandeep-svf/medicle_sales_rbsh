import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../controller/territory_controller.dart';

class OfflineMapToggle extends GetView<TerritoryController> {
  const OfflineMapToggle({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      return Container(

        margin: const EdgeInsets.symmetric(horizontal: 12),

        padding: const EdgeInsets.all(4),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(30),

          boxShadow: const [

            BoxShadow(

              color: Colors.black12,

              blurRadius: 8,

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
                        ? Colors.transparent
                        : TColors.primary,

                    borderRadius: BorderRadius.circular(25),

                  ),

                  child: Text(

                    "🌐 Online",

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      color: controller.isOfflineMode.value
                          ? Colors.black
                          : Colors.white,

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
                        : Colors.transparent,

                    borderRadius: BorderRadius.circular(25),

                  ),

                  child: Text(

                    "📦 Offline",

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      color: controller.isOfflineMode.value
                          ? Colors.white
                          : Colors.black,

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