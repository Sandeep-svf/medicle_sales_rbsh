import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';

import '../../../addDoctor/controllers/DoctroController.dart';
import '../../controller/add_investment_controller.dart';

class DoctorDropdown extends StatelessWidget {
  const DoctorDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final investmentController = Get.find<AddInvestmentController>();
    final doctorController = Get.find<DoctorListController>();

    return Obx(() {
      if (doctorController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return DropdownButtonFormField<String>(
        value: investmentController.selectedDoctorId.value.isEmpty
            ? null
            : investmentController.selectedDoctorId.value,

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

        items: doctorController.doctorList.map((doctor) {
          return DropdownMenuItem<String>(
            value: doctor.id,
            child: Text(doctor.name),
          );
        }).toList(),

        onChanged: (value) {
          if (value == null) return;

          final doctor = doctorController.doctorList.firstWhere(
                (e) => e.id == value,
          );

          investmentController.setDoctor(
            id: doctor.id,
            name: doctor.name,
          );
        },

        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select doctor";
          }
          return null;
        },
      );
    });
  }
}