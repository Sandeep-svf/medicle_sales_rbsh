import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../model/TourDay.dart';

class TourPlanValidationDialog extends StatelessWidget {
  const TourPlanValidationDialog({
    super.key,
    required this.unassignedDays,
  });

  final List<TourDay> unassignedDays;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 560,
          maxHeight: 680,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  8,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),

                    const SizedBox(height: 22),

                    _buildSectionTitle(),

                    const SizedBox(height: 12),

                    _buildMissingDays(),

                    const SizedBox(height: 18),

                    _buildInformationCard(),
                  ],
                ),
              ),
            ),

            _buildActions(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        22,
        16,
        22,
      ),
      decoration: BoxDecoration(
        color: TColors.warning.withOpacity(.10),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(
            color: TColors.warning.withOpacity(.12),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TColors.warning.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: TColors.warning,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Tour Plan Incomplete",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Complete all required working days "
                      "before saving the draft.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: TColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: "Close",
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.close,
              color: TColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColors.primary_shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.primary.withOpacity(.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              "${unassignedDays.length}",
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: TColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Days need attention",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "A working day cannot be left "
                      "without a plan.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: TColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Missing Plans",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: TColors.error.withOpacity(.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${unassignedDays.length} missing",
            style: const TextStyle(
              color: TColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MISSING DAYS
  // ============================================================

  Widget _buildMissingDays() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TColors.borderSecondary,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics:
        const NeverScrollableScrollPhysics(),
        itemCount: unassignedDays.length,
        separatorBuilder: (_, __) {
          return const Divider(
            height: 1,
            indent: 64,
          );
        },
        itemBuilder: (context, index) {
          final day = unassignedDays[index];

          return _buildDayTile(
            day,
            index,
          );
        },
      ),
    );
  }

  // ============================================================
  // DAY TILE
  // ============================================================

  Widget _buildDayTile(
      TourDay day,
      int index,
      ) {
    final date = day.date;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: TColors.error.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              date.day.toString(),
              style: const TextStyle(
                color: TColors.error,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _weekday(date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _fullDate(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.error_outline_rounded,
            color: TColors.error,
            size: 21,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION
  // ============================================================

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.softGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 19,
            color: TColors.textSecondary,
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              "Holiday and Weekly Off days are "
                  "automatically excluded from this validation. "
                  "All other days must have a plan.",
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: TColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        14,
        24,
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: TColors.borderSecondary,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Get.back();
              },
              style: OutlinedButton.styleFrom(
                minimumSize:
                const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Close",
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                minimumSize:
                const Size.fromHeight(46),
                backgroundColor:
                TColors.primary,
                foregroundColor:
                Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.edit_calendar_outlined,
                size: 18,
              ),
              label: const Text(
                "Review Days",
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  String _weekday(DateTime date) {
    const names = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return names[date.weekday - 1];
  }

  String _fullDate(DateTime date) {
    const months = [
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

    return "${date.day.toString().padLeft(2, '0')} "
        "${months[date.month - 1]} "
        "${date.year}";
  }
}