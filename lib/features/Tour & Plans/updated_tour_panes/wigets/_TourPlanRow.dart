import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/updated_tour_panes/wigets/status_chip.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../model/tour_plan_model.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class TourPlanRow extends StatefulWidget {
  const TourPlanRow({
    super.key,
    required this.index,
    required this.plan,
    required this.onDetails,
    required this.onSubmit,
    required this.isSubmitting,
    required this.submitEnabled,
  });

  final int index;
  final TourPlanModel plan;
  final VoidCallback onDetails;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final bool submitEnabled;

  @override
  State<TourPlanRow> createState() => TourPlanRowState();
}

class TourPlanRowState extends State<TourPlanRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    final rowColor = _hover
        ? TColors.primary.withValues(alpha: .04)
        : widget.index.isEven
            ? TColors.white
            : TColors.primary_shade50.withValues(alpha: .35);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
      },
      onExit: (_) {
        setState(() => _hover = false);
      },
      child: InkWell(
        onTap: widget.onDetails,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: rowColor,
            border: const Border(
              bottom: BorderSide(color: TColors.borderSecondary),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.lg,
            vertical: TSizes.md,
          ),
          child: Row(
            children: [
              /// MONTH
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.monthName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: TSizes.v16,
                      ),
                    ),
                    const SizedBox(height: TSizes.v4),
                    Text(
                      "Created ${_date(plan.createdAt)}",
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: TSizes.v12,
                      ),
                    ),
                  ],
                ),
              ),

              /// STATUS
              Expanded(
                flex: 2,
                child: Center(
                  child: StatusChip(
                    status: plan.status,
                  ),
                ),
              ),

              /// DAYS
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.primary_shade50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      "${plan.days.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              /// REMARKS
              Expanded(
                flex: 4,
                child: _remarks(plan),
              ),

              /// ACTION
              Expanded(
                flex: 5,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _actionButton(plan),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //--------------------------------------------

  Widget _remarks(
    TourPlanModel plan,
  ) {
    if ((plan.comments ?? "").isEmpty) {
      return const Text(
        TTexts.uiTextNoRemarks,
        style: TextStyle(
          color: TColors.textSecondary,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColors.materialRed.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        plan.comments!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: TColors.materialRed,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  //--------------------------------------------

  Widget _actionButton(
    TourPlanModel plan,
  ) {
    return Wrap(
      spacing: TSizes.v8,
      runSpacing: TSizes.v6,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: widget.onDetails,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          ),
          icon: const Icon(Icons.visibility_outlined, size: TSizes.v17),
          label: const Text(TTexts.uiTextView),
        ),
        if (plan.isDraft)
          OutlinedButton.icon(
            onPressed: widget.onDetails,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
            icon: const Icon(Icons.edit_outlined, size: TSizes.v17),
            label: const Text(TTexts.uiTextEdit),
          ),
        if (plan.isDraft)
          ElevatedButton.icon(
            onPressed: widget.submitEnabled ? widget.onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
            icon: widget.isSubmitting
                ? const SizedBox(
                    width: TSizes.v16,
                    height: TSizes.v16,
                    child: CircularProgressIndicator(
                      strokeWidth: TSizes.v2,
                      color: TColors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: TSizes.v17),
            label: Text(widget.isSubmitting ? "Submitting" : "Submit"),
          ),
        if (plan.isReturned)
          ElevatedButton.icon(
            onPressed: widget.onDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.materialRed,
              foregroundColor: TColors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
            icon: const Icon(Icons.refresh_rounded, size: TSizes.v17),
            label: const Text(TTexts.uiTextRevise),
          ),
      ],
    );
  }

  //--------------------------------------------

  String _date(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
