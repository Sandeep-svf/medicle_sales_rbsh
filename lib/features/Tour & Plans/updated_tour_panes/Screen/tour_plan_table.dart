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
  });

  final List<TourPlanModel> plans;
  final Function(TourPlanModel) onDetails;

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
            color: TColors.primary,
            child: Row(
              children: [

                const Icon(
                  Icons.table_chart,
                  color: Colors.white,
                ),

                const SizedBox(width: 10),

                Text(
                  "Tour Plans (${plans.length})",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  "Updated Recently",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          _buildHeader(),

          const Divider(
            height: 1,
            thickness: 1,
          ),

          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];

                  return TourPlanRow(
                    key: ValueKey(plan.id),
                    index: index,
                    plan: plan,
                    onDetails: () => onDetails(plan),
                  );
                },
              ),
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
            flex: 2,
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
            flex: 3,
            child: Text(
              "Updated",
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
            flex: 2,
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