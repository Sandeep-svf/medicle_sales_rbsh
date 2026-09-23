import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../model/TourDay.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class TourPlanValidationDialog extends StatelessWidget {
  const TourPlanValidationDialog({
    super.key,
    required this.unassignedDays,
  });

  final List<TourDay> unassignedDays;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: TColors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: TSizes.v560,
          maxHeight: TSizes.v680,
        ),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: TColors.pureBlack.withOpacity(.15),
              blurRadius: TSizes.v30,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: TSizes.v22),
                    _buildSectionTitle(),
                    const SizedBox(height: TSizes.v12),
                    _buildMissingDays(),
                    const SizedBox(height: TSizes.v18),
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
            width: TSizes.v48,
            height: TSizes.v48,
            decoration: BoxDecoration(
              color: TColors.warning.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: TColors.warning,
              size: TSizes.v28,
            ),
          ),
          const SizedBox(width: TSizes.v14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TTexts.uiTextTourPlanIncomplete,
                  style: TextStyle(
                    fontSize: TSizes.v19,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: TSizes.v4),
                Text(
                  TTexts.uiTextCompleteAllRequiredWorkingDays +
                      "before saving the draft.",
                  style: TextStyle(
                    fontSize: TSizes.v13,
                    height: TSizes.v1_35,
                    color: TColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: TTexts.uiTextClose,
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
            width: TSizes.v62,
            height: TSizes.v62,
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              "${unassignedDays.length}",
              style: const TextStyle(
                fontSize: TSizes.v25,
                fontWeight: FontWeight.w800,
                color: TColors.primary,
              ),
            ),
          ),
          const SizedBox(width: TSizes.v16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TTexts.uiTextDaysNeedAttention,
                  style: TextStyle(
                    fontSize: TSizes.v16,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: TSizes.v5),
                Text(
                  TTexts.uiTextAWorkingDayCannotBeLeft + "without a plan.",
                  style: TextStyle(
                    fontSize: TSizes.v13,
                    height: TSizes.v1_35,
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
            TTexts.uiTextMissingPlans,
            style: TextStyle(
              fontSize: TSizes.v15,
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
              fontSize: TSizes.v11,
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
        color: TColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TColors.borderSecondary,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: unassignedDays.length,
        separatorBuilder: (_, __) {
          return const Divider(
            height: TSizes.v1,
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
            width: TSizes.v38,
            height: TSizes.v38,
            decoration: BoxDecoration(
              color: TColors.error.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              date.day.toString(),
              style: const TextStyle(
                color: TColors.error,
                fontSize: TSizes.v15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: TSizes.v12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weekday(date),
                  style: const TextStyle(
                    fontSize: TSizes.v13,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: TSizes.v3),
                Text(
                  _fullDate(date),
                  style: const TextStyle(
                    fontSize: TSizes.v12,
                    color: TColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.error_outline_rounded,
            color: TColors.error,
            size: TSizes.v21,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: TSizes.v19,
            color: TColors.textSecondary,
          ),
          const SizedBox(width: TSizes.v10),
          const Expanded(
            child: Text(
              TTexts.uiTextHolidayAndWeeklyOffDaysAre +
                  "automatically excluded from this validation. "
                      "All other days must have a plan.",
              style: TextStyle(
                fontSize: TSizes.v12,
                height: TSizes.v1_45,
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
        color: TColors.white,
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
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                TTexts.uiTextClose,
              ),
            ),
          ),
          const SizedBox(width: TSizes.v12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: TColors.primary,
                foregroundColor: TColors.white,
                elevation: TSizes.v0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.edit_calendar_outlined,
                size: TSizes.v18,
              ),
              label: const Text(
                TTexts.uiTextReviewDays,
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
