import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/report/screens/widgets/customer_feedback.dart';
import 'package:medicle_sales_rbsh/features/report/screens/widgets/export_report_button.dart';
import 'package:medicle_sales_rbsh/features/report/screens/widgets/sales_performance.dart';
import 'package:medicle_sales_rbsh/features/report/screens/widgets/visit_frequency.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// Sales Performance
            SalesPerformances(),

            /// Visit Frequency
            VisitFrequency(),

            /// Customer Satisfaction feedback
            CustomerFeedback(),

            SizedBox(
              height: TSizes.spaceBtwSections,
            ),

            /// Export Report Button
            ExportReportButton(),
          ],
        ),
      ),
    );
  }
}
