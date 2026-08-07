import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/DCR/wigets/performance_row.dart';
import 'package:medicle_sales_rbsh/features/DCR/wigets/table_header.dart';

import '../../../utils/constants/colors.dart';
import '../model/performance_model.dart';

class PerformanceTable extends StatelessWidget {
  final List<PerformanceModel> employees;
  final SortColumn sortColumn;
  final bool ascending;
  final ValueChanged<SortColumn> onSort;

  const PerformanceTable({
    super.key,
    required this.employees,
    required this.sortColumn,
    required this.ascending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TColors.borderSecondary),
      ),
      child: Column(
        children: [

          TableHeader(
            sortColumn: sortColumn,
            ascending: ascending,
            onSort: onSort,
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: employees.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              return PerformanceRow(
                employee: employees[index],
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }
}