import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../model/area_model.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class AreaDetailsBottomSheet extends GetView<TerritoryController> {
  final AreaModel area;

  const AreaDetailsBottomSheet({
    super.key,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final beats = controller.beatsForArea(area.id);

    return Material(
      color: TColors.white,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(28),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(TSizes.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///////////////////////////////////////////////////////
                /// HANDLE
                ///////////////////////////////////////////////////////

                Center(
                  child: Container(
                    width: TSizes.v55,
                    height: TSizes.v5,
                    decoration: BoxDecoration(
                      color: TColors.materialGrey400,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.v20),

                ///////////////////////////////////////////////////////
                /// HEADER
                ///////////////////////////////////////////////////////

                Row(
                  children: [
                    CircleAvatar(
                      radius: TSizes.v26,
                      backgroundColor: TColors.primary.withOpacity(.12),
                      child: const Icon(
                        Icons.location_city,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(width: TSizes.v16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.postOffice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: TSizes.fontSizeLg,
                            ),
                          ),
                          Text(
                            area.pincode,
                            style: TextStyle(
                              color: TColors.materialGrey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: TSizes.v24),

                ///////////////////////////////////////////////////////
                /// STATS
                ///////////////////////////////////////////////////////

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        Icons.local_hospital,
                        area.doctorCount.toString(),
                        "Doctors",
                      ),
                    ),
                    const SizedBox(width: TSizes.v12),
                    Expanded(
                      child: _statCard(
                        Icons.route,
                        beats.length.toString(),
                        "Beats",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: TSizes.v24),

                const Text(
                  TTexts.uiTextAssignedBeats,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: TSizes.fontSizeMd,
                  ),
                ),

                const SizedBox(height: TSizes.v10),

                if (beats.isEmpty)
                  const Text(
                    TTexts.uiTextNoBeatAssigned,
                  )
                else
                  ...beats.map(
                    (beat) => Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.route,
                        ),
                        title: Text(
                          beat.beatName,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: TSizes.v24),

                ///////////////////////////////////////////////////////
                /// ACTIONS
                ///////////////////////////////////////////////////////

                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.people),
                  label: const Text(
                    TTexts.uiTextViewDoctors,
                  ),
                ),

                const SizedBox(height: TSizes.v12),

                FilledButton.icon(
                  onPressed: () {
                    Get.back();

                    controller.startBeatCreation();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    TTexts.uiTextAddToBeat,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String value,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.materialGrey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: TColors.primary,
          ),
          const SizedBox(height: TSizes.v8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: TSizes.v20,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}
