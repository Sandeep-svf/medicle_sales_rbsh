import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../model/TourDay.dart';
import 'CalendarCell.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

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

    const List<String> weekDays = [
      'SUN',
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
    ];

    // Empty cells before first day of month
    final int startIndex = days.isEmpty ? 0 : days.first.date.weekday % 7;

    return Column(
      children: [
        //------------------------------------------------------
        // Week Header
        //------------------------------------------------------
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          color: TColors.white,
          child: Row(
            children: weekDays.map((dayName) {
              final bool isSunday = dayName == "SUN";

              return Expanded(
                child: Center(
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: TSizes.v12,
                      letterSpacing: 1.1,
                      color: isSunday ? TColors.error : TColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(
          height: TSizes.v1,
          color: TColors.borderSecondary,
        ),

        //------------------------------------------------------
        // Calendar
        //------------------------------------------------------
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),

            // Total cells = blank cells + actual dates
            itemCount: startIndex + days.length,

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: TSizes.v10,
              mainAxisSpacing: TSizes.v10,
              childAspectRatio: isPortrait ? 0.90 : 1.20,
            ),

            itemBuilder: (context, index) {
              //--------------------------------------------------
              // Empty Cells
              //--------------------------------------------------
              if (index < startIndex) {
                return const SizedBox.shrink();
              }

              //--------------------------------------------------
              // Actual Day
              //--------------------------------------------------
              final day = days[index - startIndex];

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
