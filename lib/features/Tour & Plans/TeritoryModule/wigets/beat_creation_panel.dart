import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../utils/enumsclass.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class BeatCreationPanel extends GetView<TerritoryController> {
  const BeatCreationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.mapMode.value != TerritoryMapMode.createBeat) {
        return const SizedBox.shrink();
      }

      return Material(
        elevation: TSizes.v12,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.route,
                    color: TColors.primary,
                  ),
                  const SizedBox(width: TSizes.v12),
                  const Expanded(
                    child: Text(
                      TTexts.uiTextCreateBeat,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.fontSizeLg,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.cancelBeatCreation();
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  )
                ],
              ),
              const SizedBox(height: TSizes.v18),
              Row(
                children: [
                  Expanded(
                    child: _tile(
                      controller.selectedAreaCount.toString(),
                      "Areas",
                    ),
                  ),
                  Expanded(
                    child: _tile(
                      controller.selectedDoctorCount.toString(),
                      "Doctors",
                    ),
                  ),
                  Expanded(
                    child: _tile(
                      "${controller.estimatedDistance.toStringAsFixed(1)} km",
                      "Distance",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.v20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                  ),
                  onPressed: controller.canSaveBeat
                      ? () {
                          _showBeatDialog(
                            context,
                          );
                        }
                      : null,
                  icon: const Icon(
                    Icons.save,
                  ),
                  label: const Text(
                    TTexts.uiTextCreateBeat,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _tile(
    String value,
    String title,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: TSizes.v20,
          ),
        ),
        const SizedBox(height: TSizes.v4),
        Text(title),
      ],
    );
  }

  void _showBeatDialog(
    BuildContext context,
  ) {
    final name = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text(
          TTexts.uiTextCreateBeat,
        ),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(
            labelText: TTexts.uiTextBeatName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text(
              TTexts.cancel,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.createBeat();

              Get.back();
            },
            child: const Text(
              TTexts.uiTextCreate,
            ),
          )
        ],
      ),
    );
  }
}
