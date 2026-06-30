import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../controller/add_investment_controller.dart';



class DoctorInfoCard extends GetView<AddInvestmentController> {
  const DoctorInfoCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      final doctor =
          controller.selectedDoctor.value ?? "";

      return Container(

        width: double.infinity,

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(

          color: TColors.primary.withOpacity(.04),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: TColors.primary.withOpacity(.15),
          ),

        ),

        child: Row(

          children: [

            CircleAvatar(

              radius:30,

              backgroundColor:
              TColors.primary.withOpacity(.12),

              child: Text(

                doctor.isEmpty
                    ? "?"
                    : doctor[0],

                style: const TextStyle(

                  color: TColors.primary,

                  fontSize:22,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

            const SizedBox(width:16),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    doctor,

                    style: const TextStyle(

                      fontSize:18,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height:6),

                  Text(

                    "Dermatologist",

                    style: TextStyle(

                      color: Colors.grey.shade700,

                    ),

                  ),

                  const SizedBox(height:10),

                  Wrap(

                    spacing:8,

                    children: [

                      _chip(
                        "Priority A",
                        Colors.red,
                      ),

                      _chip(
                        "Active",
                        Colors.green,
                      ),

                    ],

                  )

                ],

              ),

            ),

          ],

        ),

      );

    });

  }

  Widget _chip(
      String text,
      Color color,
      ){

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal:12,
        vertical:6,
      ),

      decoration: BoxDecoration(

        color: color.withOpacity(.10),

        borderRadius:
        BorderRadius.circular(30),

      ),

      child: Text(

        text,

        style: TextStyle(

          color: color,

          fontWeight: FontWeight.bold,

        ),

      ),

    );

  }

}