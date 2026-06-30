import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import 'beat_card.dart';


class BeatListBottomSheet extends GetView<TerritoryController> {
  const BeatListBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {

    return Material(

      color: Colors.white,

      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(26),
      ),

      child: SafeArea(

        top: false,

        child: Padding(

          padding: const EdgeInsets.all(TSizes.md),

          child: Column(

            children: [

              Container(

                width: 55,

                height: 5,

                decoration: BoxDecoration(

                  color: Colors.grey.shade400,

                  borderRadius: BorderRadius.circular(20),

                ),

              ),

              const SizedBox(height: 20),

              Row(

                children: [

                  const Expanded(

                    child: Text(

                      "Beat Management",

                      style: TextStyle(

                        fontSize: 20,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),

                  Text(

                    "${controller.visibleBeats.length} Beats",

                  )

                ],

              ),

              const SizedBox(height: 20),

              Expanded(

                child: Obx(() {

                  return ListView.separated(

                    itemCount:
                    controller.visibleBeats.length,

                    separatorBuilder: (_,__) =>
                    const SizedBox(height:14),

                    itemBuilder: (_,index){

                      return BeatCard(

                        beat: controller.visibleBeats[index],

                      );

                    },

                  );

                }),

              )

            ],

          ),

        ),

      ),

    );

  }

}