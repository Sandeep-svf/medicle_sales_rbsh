import 'package:flutter/material.dart';

import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import 'custom_dropdown.dart';
import 'doctor_info_card.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class DoctorSection extends StatelessWidget {
  const DoctorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: TTexts.uiTextDoctorInformation,
      icon: Icons.person,
      child: Column(
        children: [
          DoctorDropdown(),
          SizedBox(height: TSizes.v20),
          DoctorInfoCard(),
        ],
      ),
    );
  }
}
