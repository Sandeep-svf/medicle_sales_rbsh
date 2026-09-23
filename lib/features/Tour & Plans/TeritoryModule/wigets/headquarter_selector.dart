import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../model/headquarter_model.dart';

class HeadquarterSelector extends GetView<TerritoryController> {
  const HeadquarterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hq = controller.selectedHeadquarter.value;

      if (hq == null) {
        return const SizedBox.shrink();
      }

      final areaCount = controller.visibleAreas.length;

      final doctorCount = controller.visibleDoctors.length;

      final beatCount = controller.visibleBeats.length;

      return Material(
        elevation: TSizes.v5,
        borderRadius: BorderRadius.circular(18),
        color: TColors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showSelector(context),
          child: Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(width: TSizes.v12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hq.name,
                            style: const TextStyle(
                              fontSize: TSizes.fontSizeMd,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            hq.state,
                            style: TextStyle(
                              color: TColors.materialGrey600,
                              fontSize: TSizes.fontSizeSm,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.expand_more)
                  ],
                ),
                const SizedBox(height: TSizes.v14),
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        Icons.location_on,
                        areaCount.toString(),
                        "Areas",
                      ),
                    ),
                    const SizedBox(width: TSizes.v10),
                    Expanded(
                      child: _infoCard(
                        Icons.local_hospital,
                        doctorCount.toString(),
                        "Doctors",
                      ),
                    ),
                    const SizedBox(width: TSizes.v10),
                    Expanded(
                      child: _infoCard(
                        Icons.route,
                        beatCount.toString(),
                        "Beats",
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _infoCard(
    IconData icon,
    String value,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: TColors.materialGrey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: TColors.primary,
            size: TSizes.v22,
          ),
          const SizedBox(height: TSizes.v6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: TSizes.fontSizeMd,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: TColors.materialGrey600,
              fontSize: TSizes.v12,
            ),
          ),
        ],
      ),
    );
  }

  void _showSelector(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.headquarters.length,
            itemBuilder: (_, index) {
              final HeadquarterModel hq = controller.headquarters[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: TColors.primary.withOpacity(.12),
                  child: const Icon(
                    Icons.apartment,
                    color: TColors.primary,
                  ),
                ),
                title: Text(
                  hq.name,
                ),
                subtitle: Text(
                  hq.state,
                ),
                trailing: controller.selectedHeadquarter.value?.id == hq.id
                    ? const Icon(
                        Icons.check_circle,
                        color: TColors.materialGreen,
                      )
                    : null,
                onTap: () {
                  Get.back();

                  controller.changeHeadquarter(hq);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
