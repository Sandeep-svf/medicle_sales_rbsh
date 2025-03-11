import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../widgets/login_visit_schedule_button.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/sales_target_chart.dart';
import '../widgets/weekly_sales_chart.dart';

class SalesChartHomeScreen extends StatelessWidget {
  const SalesChartHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Sales Target Chart
            SalesTargetChartScreen(),
            const SizedBox(
              height: TSizes.spaceBtwText,
            ),

            /// Weekly Sales Chart
            WeeklySalesChart(),
            // QuickStats
            const QuickStatsCards(),

            /// Login Activity and Schedule Visit Button
            const LoginViistScheduleButton(),

            //space
            const SizedBox(height: TSizes.spaceBtwText,)
          ],
        ),
      ),
    );
  }
}


