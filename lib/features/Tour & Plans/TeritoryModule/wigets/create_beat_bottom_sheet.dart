import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../utils/enumsclass.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class CreateBeatBottomSheet extends GetView<TerritoryController> {
  const CreateBeatBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> beatColors = [
      "#FF0000",
      "#0000FF",
      "#00AA00",
      "#FFFF00",
      "#FF8000",
      "#800080",
      "#00FFFF",
      "#FF00FF",
      "#8B4513",
      "#000000",
      "#808080",
      "#008080",
      "#800000",
      "#808000",
      "#000080",
      "#008000",
      "#FF1493",
      "#4B0082",
      "#40E0D0",
      "#B8860B",
    ];

    return Obx(() {
      if (controller.mapMode.value != TerritoryMapMode.createBeat &&
          controller.mapMode.value != TerritoryMapMode.editBeat) {
        return const SizedBox.shrink();
      }

      return Material(
        elevation: TSizes.v18,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        color: TColors.white,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              TSizes.lg,
              TSizes.md,
              TSizes.lg,
              TSizes.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ////////////////////////////////////////////////////////
                /// HANDLE
                ////////////////////////////////////////////////////////

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

                ////////////////////////////////////////////////////////
                /// HEADER
                ////////////////////////////////////////////////////////

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.route,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(width: TSizes.v14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            return Text(
                              controller.mapMode.value ==
                                      TerritoryMapMode.editBeat
                                  ? "Edit Beat"
                                  : "Create New Beat",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: TSizes.fontSizeLg,
                              ),
                            );
                          }),
                          SizedBox(height: TSizes.v2),
                          Obx(() {
                            return Text(
                              controller.mapMode.value ==
                                      TerritoryMapMode.editBeat
                                  ? "Modify existing beat"
                                  : "Select multiple areas and save as Beat",
                              style: const TextStyle(
                                color: TColors.materialGrey,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.cancelBeatCreation();
                      },
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),

                const SizedBox(height: TSizes.v28),

                ////////////////////////////////////////////////////////
                /// NAME
                ////////////////////////////////////////////////////////

                const Text(
                  TTexts.uiTextBeatName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: TSizes.v10),

                TextField(
                  controller: controller.beatNameController,
                  decoration: InputDecoration(
                    hintText: TTexts.uiTextMorningBeat,
                    prefixIcon: const Icon(Icons.edit),
                    filled: true,
                    fillColor: TColors.materialGrey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.v24),

                ////////////////////////////////////////////////////////
                /// COLOR
                ////////////////////////////////////////////////////////

                const Text(
                  TTexts.uiTextBeatColor,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: TSizes.v12),

                Obx(() {
                  return Wrap(
                    spacing: TSizes.v10,
                    children: beatColors.map((color) {
                      final selected =
                          controller.selectedBeatColor.value == color;

                      return GestureDetector(
                        onTap: () {
                          controller.selectedBeatColor.value = color;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 250,
                          ),
                          width: TSizes.v42,
                          height: TSizes.v42,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                color.replaceFirst('#', '0xFF'),
                              ),
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  selected ? TColors.pureBlack : TColors.white,
                              width: TSizes.v3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: TSizes.v6,
                                color: TColors.black12,
                              )
                            ],
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  color: TColors.white,
                                  size: TSizes.v20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                }),

                const SizedBox(height: TSizes.v28),

                ////////////////////////////////////////////////////////
                /// STATISTICS
                ////////////////////////////////////////////////////////

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        controller.selectedAreaCount.toString(),
                        "Areas",
                        Icons.location_on,
                      ),
                    ),
                    const SizedBox(width: TSizes.v12),
                    Expanded(
                      child: _statCard(
                        controller.selectedDoctorCount.toString(),
                        "Doctors",
                        Icons.local_hospital,
                      ),
                    ),
                    const SizedBox(width: TSizes.v12),
                    Expanded(
                      child: _statCard(
                        controller.estimatedDistance.toStringAsFixed(1),
                        "KM",
                        Icons.route,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: TSizes.v28),

////////////////////////////////////////////////////////
                /// SELECTED AREAS
////////////////////////////////////////////////////////

                const Text(
                  TTexts.uiTextSelectedAreas,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: TSizes.v10),

                Obx(() {
                  if (controller.selectedAreas.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: TColors.materialGrey100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          TTexts.uiTextTapAreaCirclesOnMapToSelect,
                        ),
                      ),
                    );
                  }

                  return Container(
                    constraints: const BoxConstraints(
                      maxHeight: TSizes.v180,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.materialGrey100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.selectedAreas.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: TSizes.v1),
                      itemBuilder: (_, index) {
                        final area = controller.selectedAreas[index];

                        return ListTile(
                          dense: true,
                          leading: const CircleAvatar(
                            radius: TSizes.v16,
                            child: Icon(
                              Icons.location_on,
                              size: TSizes.v16,
                            ),
                          ),
                          title: Text(area.postOffice),
                          subtitle: Text(area.pincode),
                          trailing: Text(
                            "${area.doctorCount} Doctors",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: TSizes.v24),

////////////////////////////////////////////////////////
                /// REMARK
////////////////////////////////////////////////////////

                const Text(
                  TTexts.uiTextRemark,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: TSizes.v10),

                TextField(
                  controller: controller.remarkController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: TTexts.uiTextOptionalRemark,
                    filled: true,
                    fillColor: TColors.materialGrey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.v30),

////////////////////////////////////////////////////////
                /// BUTTONS
////////////////////////////////////////////////////////

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.cancelBeatCreation();
                        },
                        child: const Text(TTexts.cancel),
                      ),
                    ),
                    const SizedBox(width: TSizes.v16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: controller.canSaveBeat
                            ? () async {
                                if (controller.mapMode.value ==
                                    TerritoryMapMode.editBeat) {
                                  await controller.updateBeat();
                                } else {
                                  await controller.createBeat();
                                }
                              }
                            : null,
                        icon: Obx(() {
                          return Icon(
                            controller.mapMode.value ==
                                    TerritoryMapMode.editBeat
                                ? Icons.edit
                                : Icons.save,
                          );
                        }),
                        label: Obx(() {
                          return Text(
                            controller.mapMode.value ==
                                    TerritoryMapMode.editBeat
                                ? "Update Beat"
                                : "Save Beat",
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _statCard(
    String value,
    String title,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
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
          const SizedBox(height: TSizes.v10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: TSizes.v20,
            ),
          ),
          const SizedBox(height: TSizes.v2),
          Text(
            title,
            style: const TextStyle(
              color: TColors.materialGrey,
            ),
          ),
        ],
      ),
    );
  }

  Color _color(BeatColor color) {
    switch (color) {
      case BeatColor.blue:
        return TColors.materialBlue;

      case BeatColor.green:
        return TColors.materialGreen;

      case BeatColor.orange:
        return TColors.materialOrange;

      case BeatColor.purple:
        return TColors.materialPurple;

      case BeatColor.red:
        return TColors.materialRed;

      case BeatColor.cyan:
        return TColors.materialCyan;
    }
  }
}
