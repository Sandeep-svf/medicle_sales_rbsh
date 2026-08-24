import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/updated_tour_panes/wigets/status_chip.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../model/tour_plan_model.dart';

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
  State<TourPlanRow> createState() =>
      TourPlanRowState();
}

class TourPlanRowState
    extends State<TourPlanRow> {

  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    final rowColor = _hover
        ? TColors.primary.withValues(alpha: .04)
        : widget.index.isEven
        ? Colors.white
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      plan.monthName,
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Created ${_date(plan.createdAt)}",
                      style: const TextStyle(
                        color:
                        TColors.textSecondary,
                        fontSize: 12,
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
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.primary_shade50,
                      borderRadius:
                      BorderRadius.circular(25),
                    ),
                    child: Text(
                      "${plan.days.length}",
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
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
                  alignment:
                  Alignment.centerRight,
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
        "No remarks",
        style: TextStyle(
          color: TColors.textSecondary,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .08),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Text(
        plan.comments!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.red,
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
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: widget.onDetails,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          ),
          icon: const Icon(Icons.visibility_outlined, size: 17),
          label: const Text("View"),
        ),
        if (plan.isDraft)
          OutlinedButton.icon(
            onPressed: widget.onDetails,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: const Text("Edit"),
          ),
        if (plan.isDraft)
          ElevatedButton.icon(
            onPressed: widget.submitEnabled ? widget.onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
            icon: widget.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 17),
            label: Text(widget.isSubmitting ? "Submitting" : "Submit"),
          ),
        if (plan.isReturned)
          ElevatedButton.icon(
            onPressed: widget.onDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text("Revise"),
          ),
      ],
    );
  }

  //--------------------------------------------

  String _date(DateTime date) {

    return

      "${date.day.toString().padLeft(2, '0')}/"

          "${date.month.toString().padLeft(2, '0')}/"

          "${date.year}";
  }
}
