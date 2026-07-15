import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../model/pending_approval_model.dart';

class PendingApprovalCard extends StatelessWidget {
  const PendingApprovalCard({
    super.key,
    required this.plan,
    required this.onView,
    required this.onApprove,
    required this.onReturn,
    required this.loading,
  });

  final PendingApprovalModel plan;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onReturn;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TSizes.cardElevation,
      color: TColors.cardBackground,
      surfaceTintColor: Colors.transparent,
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

            /// Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        plan.user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TColors.textPrimary,
                        ),
                      ),

                      const SizedBox(
                        height: TSizes.xs,
                      ),

                      Text(
                        plan.user.employeeCode ?? "-",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: TColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                _StatusChip(status: plan.status),
              ],
            ),

            const SizedBox(
              height: TSizes.lg,
            ),

            const Divider(),

            const SizedBox(
              height: TSizes.md,
            ),

            _InfoRow(
              title: "Planning Month",
              value:
              "${DateFormat.MMMM().format(DateTime(plan.year, plan.month))} ${plan.year}",
            ),

            const SizedBox(
              height: TSizes.spaceBtwItems,
            ),

            _InfoRow(
              title: "Submitted On",
              value: DateFormat("dd MMM yyyy")
                  .format(plan.createdAt),
            ),

            const Spacer(),

            const Divider(),

            const SizedBox(
              height: TSizes.md,
            ),

            Row(
              children: [

                OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text("View"),
                ),

                const Spacer(),

                OutlinedButton(
                  onPressed:
                  loading ? null : onReturn,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TColors.warning,
                  ),
                  child: const Text("Return"),
                ),

                const SizedBox(
                  width: TSizes.sm,
                ),

                FilledButton(
                  onPressed:
                  loading ? null : onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    TColors.primary,
                  ),
                  child: const Text("Approve"),
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

    Color background = TColors.primary_shade50;
    Color text = TColors.primary;

    switch (status.toLowerCase()) {

      case "approved":
        background = TColors.successBg;
        text = TColors.success;
        break;

      case "returned":
        background = TColors.warningBg;
        text = TColors.warning;
        break;

      case "rejected":
        background = TColors.errorBg;
        text = TColors.error;
        break;

      case "submitted":
        background = TColors.primary_shade50;
        text = TColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.md,
        vertical: TSizes.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          TSizes.cardRadiusLg,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: TSizes.fontSizeSm,
        ),
      ),
    );
  }
}