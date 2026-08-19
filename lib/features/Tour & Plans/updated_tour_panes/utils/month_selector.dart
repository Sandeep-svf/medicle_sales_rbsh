import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.selectedMonth,
  });

  final DateTime selectedMonth;

  static const List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  // ------------------------------------------------------------
  // Planning Range
  // ------------------------------------------------------------
  //
  // User can select:
  //
  // Next month
  // up to
  // 3 years from the current month.
  //
  // Example:
  // Today = August 2026
  //
  // First  = September 2026
  // Last   = August 2029
  //
  // ------------------------------------------------------------

  static const int futureYears = 3;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final currentMonth = DateTime(
      now.year,
      now.month,
    );

    // First selectable month = next month
    final firstMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
    );

    // Last selectable month = same month,
    // 3 years in the future.
    final lastMonth = DateTime(
      currentMonth.year + futureYears,
      currentMonth.month,
    );

    return Dialog(
      backgroundColor: Colors.transparent,

      insetPadding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),

      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),
        ),

        child: Column(
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),

              decoration:
              const BoxDecoration(
                color: TColors.primary,

                borderRadius:
                BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 26,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  const Expanded(
                    child: Text(
                      "Select Planning Month",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // RANGE INFORMATION
            // ==================================================

            Container(
              width: double.infinity,

              margin:
              const EdgeInsets.all(16),

              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              decoration: BoxDecoration(
                color:
                TColors.primary_shade50,

                borderRadius:
                BorderRadius.circular(12),

                border: Border.all(
                  color: TColors.primary
                      .withOpacity(.15),
                ),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.event_available,
                    color: TColors.primary,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Planning period",
                          style: TextStyle(
                            fontSize: 12,
                            color:
                            TColors
                                .textSecondary,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          "${_monthTitle(firstMonth)}"
                              " - "
                              "${_monthTitle(lastMonth)}",

                          style:
                          const TextStyle(
                            color:
                            TColors.primary,
                            fontSize: 14,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // SELECTED MONTH
            // ==================================================

            Container(
              width: double.infinity,

              margin:
              const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 12,
              ),

              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.grey.shade50,

                borderRadius:
                BorderRadius.circular(10),

                border: Border.all(
                  color:
                  TColors.borderSecondary,
                ),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.check_circle_outline,
                    color: TColors.primary,
                    size: 20,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  const Text(
                    "Selected:",
                    style: TextStyle(
                      color:
                      TColors
                          .textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Text(
                    _monthTitle(
                      selectedMonth,
                    ),

                    style:
                    const TextStyle(
                      color:
                      TColors.primary,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // YEARS + MONTHS
            // ==================================================

            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  20,
                ),

                itemCount:
                lastMonth.year -
                    firstMonth.year +
                    1,

                itemBuilder:
                    (context, index) {

                  final year =
                      firstMonth.year +
                          index;

                  return _buildYear(
                    context,
                    year,
                    firstMonth,
                    lastMonth,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // YEAR
  // ============================================================

  Widget _buildYear(
      BuildContext context,
      int year,
      DateTime firstMonth,
      DateTime lastMonth,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Padding(
          padding:
          const EdgeInsets.only(
            top: 12,
            bottom: 10,
          ),

          child: Text(
            year.toString(),

            style: const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ),

        GridView.builder(
          shrinkWrap: true,

          physics:
          const NeverScrollableScrollPhysics(),

          itemCount: 12,

          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),

          itemBuilder:
              (context, index) {

            final month =
                index + 1;

            final monthDate =
            DateTime(
              year,
              month,
            );

            final isAvailable =
                !monthDate.isBefore(
                  firstMonth,
                ) &&
                    !monthDate.isAfter(
                      lastMonth,
                    );

            final isSelected =
                selectedMonth.year ==
                    year &&
                    selectedMonth.month ==
                        month;

            return InkWell(
              borderRadius:
              BorderRadius.circular(
                10,
              ),

              onTap: !isAvailable
                  ? null
                  : () {

                Navigator.pop(
                  context,
                  monthDate,
                );
              },

              child: AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 150,
                ),

                alignment:
                Alignment.center,

                decoration:
                BoxDecoration(
                  color: !isAvailable
                      ? Colors.grey.shade100
                      : isSelected
                      ? TColors.primary
                      : TColors
                      .primary_shade50,

                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),

                  border:
                  Border.all(
                    color: !isAvailable
                        ? Colors
                        .grey
                        .shade300
                        : isSelected
                        ? TColors.primary
                        : TColors
                        .borderSecondary,
                  ),
                ),

                child: Text(
                  months[index],

                  style: TextStyle(
                    color: !isAvailable
                        ? Colors
                        .grey
                        .shade400
                        : isSelected
                        ? Colors.white
                        : TColors
                        .textPrimary,

                    fontSize: 13,

                    fontWeight:
                    isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  // ============================================================
  // MONTH TITLE
  // ============================================================

  String _monthTitle(
      DateTime date,
      ) {
    return "${months[date.month - 1]} "
        "${date.year}";
  }
}