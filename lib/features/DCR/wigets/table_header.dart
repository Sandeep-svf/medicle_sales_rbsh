import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

enum SortColumn {
  employee,
  doctor,
  chemist,
  stockist,
  coverage,
}

class TableHeader extends StatelessWidget {
  final SortColumn sortColumn;
  final bool ascending;
  final ValueChanged<SortColumn>? onSort;

  const TableHeader({
    super.key,
    required this.sortColumn,
    required this.ascending,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [

          _header(
            title: "Employee",
            column: SortColumn.employee,
            flex: 3,
          ),

          _header(
            title: "Doctors",
            subtitle: "Sch / Conf / %",
            column: SortColumn.doctor,
            flex: 2,
          ),

          _header(
            title: "Chemists",
            subtitle: "Sch / Conf / %",
            column: SortColumn.chemist,
            flex: 2,
          ),

          _header(
            title: "Stockists",
            subtitle: "Sch / Conf / %",
            column: SortColumn.stockist,
            flex: 2,
          ),

          _header(
            title: "Coverage",
            column: SortColumn.coverage,
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _header({
    required String title,
    required SortColumn column,
    required int flex,
    String? subtitle,
  }) {
    final selected = sortColumn == column;

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => onSort?.call(column),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: double.infinity,
          child: Row(
            children: [

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),

                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              AnimatedRotation(
                turns: selected
                    ? (ascending ? 0 : 0.5)
                    : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(.35),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}