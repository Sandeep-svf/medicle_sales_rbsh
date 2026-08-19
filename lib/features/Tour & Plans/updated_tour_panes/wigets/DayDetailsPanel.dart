import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../DayType.dart';
import '../model/TourDay.dart';

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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: TColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(day.date),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Day Details",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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

          const SizedBox(height: 20),

          const Divider(),

          const SizedBox(height: 12),

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

                  const SizedBox(height: 20),

                  /// Beat
                  if (day.beatId != null ||
                      day.beatName != null ||
                      day.beatId2 != null ||
                      day.beatName2 != null) ...[
                    _sectionTitle(
                      "Beat Details",
                      Icons.location_on_outlined,
                    ),

                    if (day.beatId != null ||
                        day.beatName != null)
                      _beatCard(
                        title: "Beat 1",
                        id: day.beatId,
                        name: day.beatName,
                      ),

                    if (day.beatId2 != null ||
                        day.beatName2 != null)
                      _beatCard(
                        title: "Beat 2",
                        id: day.beatId2,
                        name: day.beatName2,
                      ),

                    const SizedBox(height: 20),
                  ],

                  /// Joint Work
                  if (day.jointWorkUserIds.isNotEmpty ||
                      day.jointWorkUserNames.isNotEmpty) ...[
                    _sectionTitle(
                      "Joint Work",
                      Icons.people_alt_outlined,
                    ),

                    _jointWorkCard(),

                    const SizedBox(height: 20),
                  ],

                  /// Notes
                  _sectionTitle(
                    "Remarks / Notes",
                    Icons.notes_outlined,
                  ),

                  _notesCard(),

                  const SizedBox(height: 20),

                  /// IDs / backend information
                  if (day.id != null ||
                      day.tourPlanId != null) ...[
                    _sectionTitle(
                      "Record Information",
                      Icons.fingerprint,
                    ),

                    if (day.id != null)
                      _detailRow(
                        "Day ID",
                        day.id!,
                        Icons.tag,
                      ),

                    if (day.tourPlanId != null)
                      _detailRow(
                        "Tour Plan ID",
                        day.tourPlanId!,
                        Icons.assignment_outlined,
                      ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Close
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              label: const Text("Close"),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
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
            size: 18,
            color: TColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
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
        color: Colors.grey.shade50,
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
            size: 18,
            color: TColors.textSecondary,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 145,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: TColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
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
    String? id,
    String? name,
  }) {
    final displayName =
    name?.trim().isNotEmpty == true
        ? name!
        : "Not available";

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
              fontSize: 12,
              color: TColors.textSecondary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            displayName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (id != null) ...[
            const SizedBox(height: 5),
            Text(
              "ID: $id",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
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
        color: Colors.deepPurple.withOpacity(.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.withOpacity(.15),
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
                      size: 18,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
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
              "No joint work user assigned",
              style: TextStyle(
                fontSize: 13,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.borderSecondary,
        ),
      ),
      child: Text(
        notes.isEmpty ? "No remarks added." : notes,
        style: TextStyle(
          fontSize: 13,
          color: notes.isEmpty
              ? TColors.textSecondary
              : TColors.textPrimary,
          height: 1.5,
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