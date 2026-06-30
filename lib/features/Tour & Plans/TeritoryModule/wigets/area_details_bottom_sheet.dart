import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../model/area_model.dart';

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

      color: Colors.white,

      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(28),
      ),

      child: SafeArea(

        top: false,

        child: Padding(

          padding: const EdgeInsets.all(TSizes.lg),

          child: SingleChildScrollView(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                ///////////////////////////////////////////////////////
                /// HANDLE
                ///////////////////////////////////////////////////////

                Center(

                  child: Container(

                    width: 55,

                    height: 5,

                    decoration: BoxDecoration(

                      color: Colors.grey.shade400,

                      borderRadius:
                      BorderRadius.circular(30),

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                ///////////////////////////////////////////////////////
                /// HEADER
                ///////////////////////////////////////////////////////

                Row(

                  children: [

                    CircleAvatar(

                      radius: 26,

                      backgroundColor:
                      TColors.primary.withOpacity(.12),

                      child: const Icon(

                        Icons.location_city,

                        color: TColors.primary,

                      ),

                    ),

                    const SizedBox(width: 16),

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

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

                              color: Colors.grey.shade600,

                            ),

                          ),

                        ],

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 24),

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

                    const SizedBox(width: 12),

                    Expanded(

                      child: _statCard(

                        Icons.route,

                        beats.length.toString(),

                        "Beats",

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 24),

                const Text(

                  "Assigned Beats",

                  style: TextStyle(

                    fontWeight: FontWeight.bold,

                    fontSize: TSizes.fontSizeMd,

                  ),

                ),

                const SizedBox(height: 10),

                if (beats.isEmpty)

                  const Text(
                    "No Beat Assigned",
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

                const SizedBox(height: 24),

                ///////////////////////////////////////////////////////
                /// ACTIONS
                ///////////////////////////////////////////////////////

                FilledButton.icon(

                  onPressed: () {

                  },

                  icon: const Icon(Icons.people),

                  label: const Text(
                    "View Doctors",
                  ),

                ),

                const SizedBox(height: 12),

                FilledButton.icon(

                  onPressed: () {

                    Get.back();

                    controller.startBeatCreation();

                  },

                  icon: const Icon(Icons.add),

                  label: const Text(
                    "Add To Beat",
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

        color: Colors.grey.shade100,

        borderRadius:
        BorderRadius.circular(16),

      ),

      child: Column(

        children: [

          Icon(
            icon,
            color: TColors.primary,
          ),

          const SizedBox(height: 8),

          Text(

            value,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

              fontSize: 20,

            ),

          ),

          Text(title),

        ],

      ),

    );

  }

}