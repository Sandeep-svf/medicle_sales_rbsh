import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

import '../model/tour_plan_model.dart';
import '../wigets/_TourPlanRow.dart';


class TourPlanTable extends StatelessWidget {
  const TourPlanTable({
    super.key,
    required this.plans,
    required this.onDetails,
    required this.onSubmit,
    required this.submittingPlanId,
  });

  final List<TourPlanModel> plans;
  final Function(TourPlanModel) onDetails;
  final Function(TourPlanModel) onSubmit;
  final String submittingPlanId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(TSizes.lg),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(TSizes.cardRadiusLg),
        side: const BorderSide(
          color: TColors.borderSecondary,
        ),
      ),
      child: Column(
        children: [

          /// Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.lg,
              vertical: TSizes.md,
            ),
            color: Colors.white,
            child: Row(
              children: [

                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TColors.primary_shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.table_chart_rounded,
                    color: TColors.primary,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Tour Plans (${plans.length})",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 1200
                    ? 1200.0
                    : constraints.maxWidth;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        _buildHeader(),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount: plans.length,
                              itemBuilder: (context, index) {
                                final plan = plans[index];

                                return TourPlanRow(
                                  key: ValueKey(plan.id),
                                  index: index,
                                  plan: plan,
                                  onDetails: () => onDetails(plan),
                                  onSubmit: () => onSubmit(plan),
                                  isSubmitting: submittingPlanId == plan.id,
                                  submitEnabled: submittingPlanId.isEmpty,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: TColors.primary_shade50,
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.lg,
        vertical: TSizes.md,
      ),
      child: const Row(
        children: [

          Expanded(
            flex: 3,
            child: Text(
              "Month",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Status",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Days",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Text(
              "Remarks",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Action",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
