import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../../model/beat_change_request_model.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class BeatChangeRequestCard extends StatelessWidget {
  const BeatChangeRequestCard({
    super.key,
    required this.request,
    required this.loading,
    required this.onApprove,
    required this.onReject,
  });

  final BeatChangeRequestModel request;
  final bool loading;

  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TSizes.v0,
      color: TColors.white,
      margin: const EdgeInsets.only(bottom: TSizes.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: TColors.borderSecondary,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-------------------------------------------------------
            // Header
            //-------------------------------------------------------

            Row(
              children: [
                CircleAvatar(
                  radius: TSizes.v24,
                  backgroundColor: TColors.primary_shade50,
                  child: Text(
                    request.employeeName.isNotEmpty
                        ? request.employeeName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: TColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.v14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: TSizes.v17,
                        ),
                      ),
                      const SizedBox(height: TSizes.v3),
                      Text(
                        "Employee Code : ${request.employeeCode}",
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontSize: TSizes.v13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.materialOrange100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    request.status,
                    style: const TextStyle(
                      color: TColors.materialOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TSizes.v20),
            //-------------------------------------------------------
            // Date
            //-------------------------------------------------------

            _InfoRow(
              icon: Icons.calendar_month_outlined,
              title: TTexts.date,
              value: request.date,
            ),

            const SizedBox(height: TSizes.v18),

            //-------------------------------------------------------
            // Beat Change
            //-------------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.lightGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: TColors.primary,
                        size: TSizes.v18,
                      ),
                      const SizedBox(width: TSizes.v8),
                      const Text(
                        TTexts.uiTextCurrentBeat,
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.v8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      request.currentBeatName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.v16,
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.v12),
                  const Icon(
                    Icons.arrow_downward_rounded,
                    color: TColors.primary,
                  ),
                  const SizedBox(height: TSizes.v12),
                  Row(
                    children: [
                      const Icon(
                        Icons.flag_circle_outlined,
                        color: TColors.materialGreen,
                        size: TSizes.v18,
                      ),
                      const SizedBox(width: TSizes.v8),
                      const Text(
                        TTexts.uiTextRequestedBeat,
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.v8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      request.requestedBeatName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.v16,
                        color: TColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.v18),

            //-------------------------------------------------------
            // Day Type
            //-------------------------------------------------------

            _InfoRow(
              icon: Icons.work_outline,
              title: TTexts.uiTextDayType,
              value: request.dayType,
            ),

            const SizedBox(height: TSizes.v18),

            //-------------------------------------------------------
            // Reason
            //-------------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TColors.primary_shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    TTexts.uiTextReason,
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TSizes.v8),
                  Text(
                    request.reason,
                    style: const TextStyle(
                      fontSize: TSizes.v15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.v22),
            //-------------------------------------------------------
            // Action Buttons
            //-------------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : onReject,
                    icon: const Icon(
                      Icons.close,
                      color: TColors.error,
                    ),
                    label: const Text(
                      TTexts.uiTextReject,
                      style: TextStyle(
                        color: TColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(
                        color: TColors.error,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.v12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : onApprove,
                    icon: loading
                        ? const SizedBox(
                            height: TSizes.v18,
                            width: TSizes.v18,
                            child: CircularProgressIndicator(
                              strokeWidth: TSizes.v2,
                              color: TColors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      loading ? "Please wait..." : "Approve",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.success,
                      foregroundColor: TColors.white,
                      minimumSize: const Size.fromHeight(48),
                      elevation: TSizes.v0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///--------------------------------------------------------------
/// Reusable Info Row
///--------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: TSizes.v18,
          color: TColors.primary,
        ),
        const SizedBox(width: TSizes.v10),
        Text(
          "$title :",
          style: const TextStyle(
            color: TColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
