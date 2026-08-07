import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../model/collaboration_request_model.dart';

class CollaborationRequestCard extends StatelessWidget {
  const CollaborationRequestCard({
    super.key,
    required this.request,
    required this.loading,
    required this.onAccept,
    required this.onReject,
  });

  final CollaborationRequestModel request;
  final bool loading;

  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final user = request.tourPlan.user;

    return Card(
      elevation: TSizes.cardElevation,
      surfaceTintColor: Colors.transparent,
      color: TColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        side: const BorderSide(
          color: TColors.cardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        user?.name ?? "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: TSizes.xs),

                      Text(
                        user?.employeeCode ?? "-",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color:
                          TColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                _StatusChip(
                  status:
                  request.collaborationStatus,
                ),
              ],
            ),

            const SizedBox(height: TSizes.lg),

            const Divider(),

            const SizedBox(height: TSizes.md),

            _InfoRow(
              title: "Visit Date",
              value: DateFormat("dd MMM yyyy")
                  .format(request.date),
            ),

            const SizedBox(
              height: TSizes.spaceBtwItems,
            ),

            _InfoRow(
              title: "Day Type",
              value: request.dayType,
            ),

            const SizedBox(height: TSizes.lg),

            const Divider(),

            const SizedBox(height: TSizes.md),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                    loading ? null : onReject,
                    icon: const Icon(Icons.close),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                      TColors.error,
                    ),
                    label: const Text("Reject"),
                  ),
                ),

                const SizedBox(
                  width: TSizes.md,
                ),

                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                    loading ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                      TColors.primary,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text("Accept"),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              color: TColors.textSecondary,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg = TColors.primary_shade50;
    Color fg = TColors.primary;

    switch (status.toLowerCase()) {
      case "accepted":
        bg = TColors.successBg;
        fg = TColors.success;
        break;

      case "rejected":
        bg = TColors.errorBg;
        fg = TColors.error;
        break;

      case "pending":
        bg = TColors.warningBg;
        fg = TColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.md,
        vertical: TSizes.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          TSizes.cardRadiusLg,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: TSizes.fontSizeSm,
        ),
      ),
    );
  }
}