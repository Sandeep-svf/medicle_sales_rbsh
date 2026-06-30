import 'package:flutter/material.dart';


import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import 'custom_dropdown.dart';
import 'doctor_info_card.dart';


class DoctorSection extends StatelessWidget {
  const DoctorSection({super.key});

  @override
  Widget build(BuildContext context) {

    return const SectionCard(

      title: "Doctor Information",

      icon: Icons.person,

      child: Column(

        children: [

          DoctorDropdown(),

          SizedBox(height:20),

          DoctorInfoCard(),

        ],

      ),

    );

  }
}