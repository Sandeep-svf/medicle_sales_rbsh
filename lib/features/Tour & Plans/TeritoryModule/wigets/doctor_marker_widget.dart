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
        return TColors.materialOrange;

      case VisitStatus.visited:
        return TColors.materialGreen;

      case VisitStatus.missed:
        return TColors.materialRed;
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
      width: TSizes.v42,
      height: TSizes.v42,
      decoration: BoxDecoration(
        color: TColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? TColors.primary : borderColor,
          width: selected ? 4 : 3,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: TSizes.v6,
            color: TColors.black12,
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
