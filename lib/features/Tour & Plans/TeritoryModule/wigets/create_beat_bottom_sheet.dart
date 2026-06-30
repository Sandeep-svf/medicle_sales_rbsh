import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../utils/enumsclass.dart';


class CreateBeatBottomSheet extends GetView<TerritoryController> {
  const CreateBeatBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if (controller.mapMode.value != TerritoryMapMode.createBeat &&
          controller.mapMode.value != TerritoryMapMode.editBeat) {
        return const SizedBox.shrink();
      }

      return Material(
        elevation: 18,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        color: Colors.white,
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
                    width: 55,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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

                    const SizedBox(width: 14),

                     Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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

                          SizedBox(height: 2),

                          Obx(() {

                            return Text(

                              controller.mapMode.value ==
                                  TerritoryMapMode.editBeat

                                  ? "Modify existing beat"

                                  : "Select multiple areas and save as Beat",

                              style: const TextStyle(
                                color: Colors.grey,
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

                const SizedBox(height: 28),

                ////////////////////////////////////////////////////////
                /// NAME
                ////////////////////////////////////////////////////////

                const Text(
                  "Beat Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: controller.beatNameController,
                  decoration: InputDecoration(
                    hintText: "Morning Beat",
                    prefixIcon: const Icon(Icons.edit),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ////////////////////////////////////////////////////////
                /// COLOR
                ////////////////////////////////////////////////////////

                const Text(
                  "Beat Color",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Obx(() {
                  return Wrap(
                    spacing: 10,
                    children: BeatColor.values.map((color) {

                      final selected =
                          controller.selectedBeatColor.value ==
                              color;

                      return GestureDetector(

                        onTap: () {
                          controller.selectedBeatColor.value =
                              color;
                        },

                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 250,
                          ),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _color(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? Colors.black
                                  : Colors.white,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 6,
                                color: Colors.black12,
                              )
                            ],
                          ),
                          child: selected
                              ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                              : null,
                        ),
                      );

                    }).toList(),
                  );
                }),

                const SizedBox(height: 28),

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

                    const SizedBox(width: 12),

                    Expanded(
                      child: _statCard(
                        controller.selectedDoctorCount.toString(),
                        "Doctors",
                        Icons.local_hospital,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _statCard(
                        controller.estimatedDistance
                            .toStringAsFixed(1),
                        "KM",
                        Icons.route,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 28),

////////////////////////////////////////////////////////
                /// SELECTED AREAS
////////////////////////////////////////////////////////

                const Text(
                  "Selected Areas",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Obx(() {

                  if (controller.selectedAreas.isEmpty) {

                    return Container(

                      width: double.infinity,

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Center(
                        child: Text(
                          "Tap area circles on map to select.",
                        ),
                      ),
                    );
                  }

                  return Container(

                    constraints: const BoxConstraints(
                      maxHeight: 180,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: ListView.separated(

                      shrinkWrap: true,

                      itemCount: controller.selectedAreas.length,

                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),

                      itemBuilder: (_, index) {

                        final area = controller.selectedAreas[index];

                        return ListTile(

                          dense: true,

                          leading: const CircleAvatar(
                            radius: 16,
                            child: Icon(
                              Icons.location_on,
                              size: 16,
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

                const SizedBox(height: 24),

////////////////////////////////////////////////////////
                /// REMARK
////////////////////////////////////////////////////////

                const Text(
                  "Remark",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(

                  controller: controller.remarkController,

                  maxLines: 3,

                  decoration: InputDecoration(

                    hintText: "Optional remark",

                    filled: true,

                    fillColor: Colors.grey.shade100,

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(14),

                      borderSide: BorderSide.none,

                    ),

                  ),

                ),

                const SizedBox(height: 30),

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

                        child: const Text("Cancel"),

                      ),

                    ),

                    const SizedBox(width: 16),

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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: TColors.primary,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

        ],
      ),
    );
  }

  Color _color(BeatColor color) {
    switch (color) {
      case BeatColor.blue:
        return Colors.blue;

      case BeatColor.green:
        return Colors.green;

      case BeatColor.orange:
        return Colors.orange;

      case BeatColor.purple:
        return Colors.purple;

      case BeatColor.red:
        return Colors.red;

      case BeatColor.cyan:
        return Colors.cyan;
    }
  }
}