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
  });

  final int index;
  final TourPlanModel plan;
  final VoidCallback onDetails;

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
        ? TColors.primary.withOpacity(.04)
        : widget.index.isEven
        ? Colors.white
        : TColors.primary_shade50.withOpacity(.35);

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
          color: rowColor,
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
                flex: 2,
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

              /// UPDATED
              Expanded(
                flex: 3,
                child: Text(
                  _date(plan.updatedAt),
                ),
              ),

              /// REMARKS
              Expanded(
                flex: 4,
                child: _remarks(plan),
              ),

              /// ACTION
              Expanded(
                flex: 2,
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
        "-",
        style: TextStyle(
          color: TColors.textSecondary,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.08),
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

    if (plan.isDraft) {

      return ElevatedButton.icon(
        onPressed: widget.onDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          Colors.orange,
          foregroundColor:
          Colors.white,
        ),
        icon: const Icon(
          Icons.edit,
          size: 18,
        ),
        label: const Text("Edit"),
      );
    }

    if (plan.isReturned) {

      return ElevatedButton.icon(
        onPressed: widget.onDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          Colors.red,
          foregroundColor:
          Colors.white,
        ),
        icon: const Icon(
          Icons.refresh,
          size: 18,
        ),
        label: const Text("Revise"),
      );
    }

    return ElevatedButton.icon(
      onPressed: widget.onDetails,
      style: ElevatedButton.styleFrom(
        backgroundColor:
        TColors.primary,
        foregroundColor:
        Colors.white,
      ),
      icon: const Icon(
        Icons.visibility,
        size: 18,
      ),
      label: const Text("View"),
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