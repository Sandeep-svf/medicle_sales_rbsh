import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import '../model/performance_model.dart';
import 'metric_cell.dart';
import 'performance_progress.dart';

class PerformanceRow extends StatefulWidget {
  final PerformanceModel employee;
  final int index;

  const PerformanceRow({
    super.key,
    required this.employee,
    required this.index,
  });

  @override
  State<PerformanceRow> createState() => _PerformanceRowState();
}

class _PerformanceRowState extends State<PerformanceRow> {

  bool hovering = false;

  @override
  Widget build(BuildContext context) {

    final emp = widget.employee;

    return MouseRegion(

      onEnter: (_) => setState(() => hovering = true),

      onExit: (_) => setState(() => hovering = false),

      cursor: SystemMouseCursors.click,

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 220),

        curve: Curves.easeOut,

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),

        decoration: BoxDecoration(

          color: hovering
              ? TColors.primary_shade50
              : Colors.white,

          border: Border(
            bottom: BorderSide(
              color: TColors.borderSecondary,
            ),
          ),

          boxShadow: hovering
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          ]
              : [],
        ),

        child: Row(

          children: [

            /// Employee
            Expanded(
              flex: 2,
              child: _employeeInfo(),
            ),

            /// Doctor
            Expanded(
              flex: 3,
              child: MetricCell(
                scheduled: emp.doctorScheduled,
                confirmed: emp.doctorConfirmed,
                color: Colors.blue,
              ),
            ),

            const SizedBox(width: 12),

            /// Chemist
            Expanded(
              flex: 3,
              child: MetricCell(
                scheduled: emp.chemistScheduled,
                confirmed: emp.chemistConfirmed,
                color: Colors.purple,
              ),
            ),

            const SizedBox(width: 12),

            /// Stockist
            Expanded(
              flex: 3,
              child: MetricCell(
                scheduled: emp.stockistScheduled,
                confirmed: emp.stockistConfirmed,
                color: Colors.green,
              ),
            ),

            const SizedBox(width: 20),

            /// Overall Coverage
            Expanded(
              flex: 2,
              child: _coverage(),
            ),
          ],
        ),
      ),
    )
        .animate(
      delay: Duration(
        milliseconds: widget.index * 70,
      ),
    )
        .fade()
        .slideX(begin: .10);
  }

  Widget _employeeInfo() {

    final emp = widget.employee;

    return Row(

      children: [

       /* CircleAvatar(

          radius: 26,

          backgroundColor: TColors.primary_shade100,

          child: Text(

            emp.name.substring(0, 1).toUpperCase(),

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
          ),
        ),

        const SizedBox(width: 14),*/

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                emp.name,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(

                  fontSize: 16,

                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(

                "ID : ${emp.id}",

                style: const TextStyle(
                  color: TColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coverage() {

    final coverage = widget.employee.overallCoverage;

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(

          children: [

            Text(

              "${(coverage * 100).toStringAsFixed(0)}%",

              style: TextStyle(

                color: _coverageColor(coverage),

                fontWeight: FontWeight.bold,

                fontSize: 18,
              ),
            ),

            const Spacer(),

            _badge(),
          ],
        ),

        const SizedBox(height: 10),

        PerformanceProgress(
          value: coverage,
          color: _coverageColor(coverage),
        ),
      ],
    );
  }

  Widget _badge() {

    final coverage = widget.employee.overallCoverage;

    String text;

    Color color;

    if (coverage >= .90) {

      text = "Excellent";

      color = TColors.success;

    } else if (coverage >= .75) {

      text = "Good";

      color = Colors.blue;

    } else if (coverage >= .50) {

      text = "Average";

      color = TColors.warning;

    } else {

      text = "Poor";

      color = TColors.error;
    }

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(

        color: color.withOpacity(.12),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(

        text,

        style: TextStyle(

          color: color,

          fontWeight: FontWeight.w600,

          fontSize: 12,
        ),
      ),
    );
  }

  Color _coverageColor(double coverage) {

    if (coverage >= .90) {
      return TColors.success;
    }

    if (coverage >= .75) {
      return Colors.blue;
    }

    if (coverage >= .50) {
      return TColors.warning;
    }

    return TColors.error;
  }
}