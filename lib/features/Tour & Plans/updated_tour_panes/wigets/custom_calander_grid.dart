import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../model/TourDay.dart';
import 'CalendarCell.dart';

class CustomCalendarGrid extends StatelessWidget {
  final List<TourDay> days;
  final TourDay? selectedDay;
  final Function(TourDay) onDaySelected;

  const CustomCalendarGrid({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isPortrait = screenWidth < 1000;

    const List<String> weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Column(
      children: [
        // FIXED: Added structured Weekday Header row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: TColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              final isSunday = day == 'SUN';
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.1,
                      color: isSunday ? TColors.error : TColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1, color: TColors.borderSecondary),

        // Calendar Core
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: isPortrait ? 0.90 : 1.20,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              return CalendarCell(
                day: day,
                isSelected: selectedDay?.date == day.date,
                onTap: () => onDaySelected(day),
              );
            },
          ),
        ),
      ],
    );
  }
}