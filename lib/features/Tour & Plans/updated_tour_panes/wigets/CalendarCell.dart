import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../DayType.dart';
import '../model/TourDay.dart';

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
      case DayType.holiday:
        bgColor = TColors.softGrey;
        borderColor = TColors.borderSecondary;
        break;
      case DayType.leave:
        bgColor = TColors.warning.withOpacity(0.08);
        borderColor = TColors.warning;
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
          border: Border.all(color: isSelected ? TColors.primary : borderColor, width: isSelected ? 2.2 : 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day.date.day.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: TColors.textPrimary),
            ),
            const Spacer(),
            _buildCellContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCellContent() {
    switch (day.type) {
      case DayType.field:
        return Text(day.beatName ?? "Field", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TColors.primary));
      case DayType.jointWork:
        return Text("w/ ${day.jointWorkUserName ?? 'Joint'}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TColors.textPrimary));
      case DayType.holiday:
        return Text(day.holidayName ?? "Holiday", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: TColors.textSecondary));
      case DayType.unassigned:
        return const Text("Needs Beat", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TColors.error));
      case DayType.meeting:
        return const Text("Meeting", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TColors.info));
      case DayType.leave:
        return const Text("Leave", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TColors.warning));
    }
  }
}