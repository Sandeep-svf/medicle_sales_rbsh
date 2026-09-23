import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../DayType.dart';
import '../model/TourDay.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class CalendarCell extends StatelessWidget {
  final TourDay day;
  final bool isSelected;
  final VoidCallback onTap;

  const CalendarCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("========== CalendarCell ==========");
    debugPrint("CalendarCell Date       : ${day.date}");
    debugPrint("CalendarCell DayType    : ${day.type}");
    debugPrint("CalendarCell ApiType    : ${day.apiDayType}");
    debugPrint("CalendarCell BeatName   : ${day.beatName}");
    debugPrint("CalendarCell Holiday    : ${day.holidayName}");
    debugPrint("==================================");

    Color bgColor = TColors.white;
    Color borderColor = TColors.borderPrimary;

    switch (day.type) {
      case DayType.field:
        bgColor = TColors.white;
        borderColor = TColors.primary;
        break;

      case DayType.jointWork:
        bgColor = TColors.primary_shade50;
        borderColor = TColors.primary;
        break;

      case DayType.meeting:
        bgColor = TColors.info.withOpacity(0.08);
        borderColor = TColors.info;
        break;

      case DayType.office:
        bgColor = TColors.materialIndigo.withOpacity(.08);
        borderColor = TColors.materialIndigo;
        break;

      case DayType.transit:
        bgColor = TColors.materialOrange.withOpacity(.08);
        borderColor = TColors.materialOrange;
        break;

      case DayType.leave:
        bgColor = TColors.warning.withOpacity(0.08);
        borderColor = TColors.warning;
        break;

      case DayType.holiday:
        bgColor = TColors.softGrey;
        borderColor = TColors.borderSecondary;
        break;

      case DayType.unassigned:
        bgColor = TColors.error.withOpacity(0.05);
        borderColor = TColors.error;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? TColors.primary : borderColor,
              width: isSelected ? 2.2 : 1.2),
          boxShadow: [
            BoxShadow(
                color: TColors.pureBlack.withOpacity(0.03),
                blurRadius: TSizes.v4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day.date.day.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: TSizes.v14,
                  color: TColors.textPrimary),
            ),
            const Spacer(),
            _buildCellContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCellContent() {
    // Weekly Off (Sunday)
    if (day.isWeeklyOff) {
      return const Text(
        TTexts.uiTextWeeklyOff,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: TSizes.v11,
          fontWeight: FontWeight.w600,
          color: TColors.materialRed,
        ),
      );
    }

    // Holiday
    if (day.type == DayType.holiday && !day.isWeeklyOff) {
      return Text(
        day.holidayName ?? "Holiday",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: TSizes.v11,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Field
    if (day.type == DayType.field) {
      return Text(
        (day.beatName?.trim().isNotEmpty ?? false) ? day.beatName! : "NO BEAT",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: TSizes.v11,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Other day types
    if (day.apiDayType != null && day.apiDayType!.trim().isNotEmpty) {
      return Text(
        day.apiDayType!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: TSizes.v11,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Default
    return const Text(
      TTexts.uiTextNOTASSIGNED,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: TSizes.v11,
        color: TColors.materialGrey,
      ),
    );
  }
}
