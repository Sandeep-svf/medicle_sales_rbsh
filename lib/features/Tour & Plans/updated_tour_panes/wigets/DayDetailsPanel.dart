import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../DayType.dart';
import '../model/TourDay.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class DayDetailsPanel extends StatelessWidget {
  final TourDay day;
  final VoidCallback onClose;

  const DayDetailsPanel({
    super.key,
    required this.day,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      child: Column(
        children: [
          /// Header
          Row(
            children: [
              Container(
                width: TSizes.v48,
                height: TSizes.v48,
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(width: TSizes.v14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(day.date),
                      style: const TextStyle(
                        fontSize: TSizes.v20,
                        fontWeight: FontWeight.bold,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: TSizes.v4),
                    Text(
                      TTexts.uiTextDayDetails,
                      style: TextStyle(
                        fontSize: TSizes.v12,
                        color: TColors.materialGrey600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: TSizes.v20),

          const Divider(),

          const SizedBox(height: TSizes.v12),

          /// Details
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _sectionTitle(
                    "Day Information",
                    Icons.info_outline,
                  ),

                  _detailRow(
                    "Date",
                    _formatDate(day.date),
                    Icons.calendar_today,
                  ),

                  _detailRow(
                    "Day Type",
                    _dayTypeName(day.type),
                    Icons.category_outlined,
                  ),

                  _detailRow(
                    "API Day Type",
                    _value(day.apiDayType),
                    Icons.code,
                  ),

                  _detailRow(
                    "Collaboration Status",
                    _value(day.collaborationStatus),
                    Icons.handshake_outlined,
                  ),

                  if (day.holidayName != null &&
                      day.holidayName!.trim().isNotEmpty)
                    _detailRow(
                      "Holiday",
                      day.holidayName!,
                      Icons.celebration_outlined,
                    ),

                  const SizedBox(height: TSizes.v20),

                  /// Beat
                  if (day.beatId != null ||
                      day.beatName != null ||
                      day.beatId2 != null ||
                      day.beatName2 != null) ...[
                    _sectionTitle(
                      "Beat Details",
                      Icons.location_on_outlined,
                    ),
                    if (day.beatId != null || day.beatName != null)
                      _beatCard(
                        title: TTexts.uiTextBeat1,
                        name: day.beatName,
                      ),
                    if (day.beatId2 != null || day.beatName2 != null)
                      _beatCard(
                        title: TTexts.uiTextBeat2,
                        name: day.beatName2,
                      ),
                    const SizedBox(height: TSizes.v20),
                  ],

                  /// Joint Work
                  if (day.jointWorkUserIds.isNotEmpty ||
                      day.jointWorkUserNames.isNotEmpty) ...[
                    _sectionTitle(
                      "Joint Work",
                      Icons.people_alt_outlined,
                    ),
                    _jointWorkCard(),
                    const SizedBox(height: TSizes.v20),
                  ],

                  /// Notes
                  _sectionTitle(
                    "Remarks / Notes",
                    Icons.notes_outlined,
                  ),

                  _notesCard(),

                  const SizedBox(height: TSizes.v20),
                ],
              ),
            ),
          ),

          const SizedBox(height: TSizes.v12),

          /// Close
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              label: const Text(TTexts.uiTextClose),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: TSizes.v18,
            color: TColors.primary,
          ),
          const SizedBox(width: TSizes.v8),
          Text(
            title,
            style: const TextStyle(
              fontSize: TSizes.v15,
              fontWeight: FontWeight.bold,
              color: TColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: TColors.materialGrey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: TColors.borderSecondary,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: TSizes.v18,
            color: TColors.textSecondary,
          ),
          const SizedBox(width: TSizes.v10),
          SizedBox(
            width: TSizes.v145,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: TSizes.v12,
                color: TColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: TSizes.v8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: TSizes.v13,
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _beatCard({
    required String title,
    String? name,
  }) {
    final displayName =
        name?.trim().isNotEmpty == true ? name! : "Not available";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.primary.withOpacity(.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: TSizes.v12,
              color: TColors.textSecondary,
            ),
          ),
          const SizedBox(height: TSizes.v5),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: TSizes.v15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _jointWorkCard() {
    final names = day.jointWorkUserNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.materialDeepPurple.withOpacity(.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.materialDeepPurple.withOpacity(.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (names.isNotEmpty)
            ...names.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: TSizes.v18,
                      color: TColors.materialDeepPurple,
                    ),
                    const SizedBox(width: TSizes.v8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: TSizes.v14,
                          fontWeight: FontWeight.w600,
                          color: TColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Text(
              TTexts.uiTextNoJointWorkUserAssigned,
              style: TextStyle(
                fontSize: TSizes.v13,
                color: TColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _notesCard() {
    final notes = day.notes?.trim() ?? "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.materialGrey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.borderSecondary,
        ),
      ),
      child: Text(
        notes.isEmpty ? "No remarks added." : notes,
        style: TextStyle(
          fontSize: TSizes.v13,
          color: notes.isEmpty ? TColors.textSecondary : TColors.textPrimary,
          height: TSizes.v1_5,
        ),
      ),
    );
  }

  String _value(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "-";
    }

    return value;
  }

  String _dayTypeName(DayType type) {
    switch (type) {
      case DayType.field:
        return "Field";

      case DayType.jointWork:
        return "Joint Work";

      case DayType.meeting:
        return "Meeting";

      case DayType.office:
        return "Office";

      case DayType.transit:
        return "Transit";

      case DayType.leave:
        return "Leave";

      case DayType.holiday:
        return "Holiday";

      case DayType.unassigned:
        return "Not Assigned";
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
