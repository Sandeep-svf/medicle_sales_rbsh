import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../controller/add_investment_controller.dart';



class DoctorDropdown extends GetView<AddInvestmentController> {
  const DoctorDropdown({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      return DropdownButtonFormField<String>(

        value: controller.selectedDoctor.value,

        decoration: InputDecoration(

          labelText: "Select Doctor",

          prefixIcon: const Icon(
            Icons.person_outline,
            color: TColors.primary,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),

        ),

        items: controller.doctors
            .map(
              (doctor) => DropdownMenuItem(
            value: doctor,
            child: Text(doctor),
          ),
        )
            .toList(),

        onChanged: controller.selectDoctor,

      );

    });

  }
}