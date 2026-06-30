import 'package:flutter/material.dart';


import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../model/doctor_location_model.dart';
import '../utils/enumsclass.dart';

class DoctorMarkerWidget extends StatelessWidget {
  final DoctorLocationModel doctor;

  final bool selected;

  const DoctorMarkerWidget({
    super.key,
    required this.doctor,
    this.selected = false,
  });

  Color get borderColor {
    switch (doctor.visitStatus) {
      case VisitStatus.pending:
        return Colors.orange;

      case VisitStatus.visited:
        return Colors.green;

      case VisitStatus.missed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {

    final parts = doctor.doctorName.split(" ");

    String initials = "";

    if (parts.isNotEmpty) {
      initials += parts.first.substring(0, 1);
    }

    if (parts.length > 1) {
      initials += parts.last.substring(0, 1);
    }

    return Container(

      width: 42,

      height: 42,

      decoration: BoxDecoration(

        color: Colors.white,

        shape: BoxShape.circle,

        border: Border.all(
          color: selected
              ? TColors.primary
              : borderColor,
          width: selected ? 4 : 3,
        ),

        boxShadow: const [

          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
          ),

        ],

      ),

      child: Center(

        child: Text(

          initials,

          style: const TextStyle(
            color: TColors.primary,
            fontSize: TSizes.fontSizeSm,
            fontWeight: FontWeight.bold,
          ),

        ),

      ),

    );
  }
}