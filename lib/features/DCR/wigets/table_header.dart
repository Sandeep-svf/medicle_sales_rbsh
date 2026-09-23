import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

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
      height: TSizes.v62,
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
            title: TTexts.uiTextEmployee,
            column: SortColumn.employee,
            flex: 3,
          ),
          _header(
            title: TTexts.uiTextDoctors,
            subtitle: TTexts.uiTextSchConf,
            column: SortColumn.doctor,
            flex: 2,
          ),
          _header(
            title: TTexts.uiTextChemists,
            subtitle: TTexts.uiTextSchConf,
            column: SortColumn.chemist,
            flex: 2,
          ),
          _header(
            title: TTexts.uiTextStockists,
            subtitle: TTexts.uiTextSchConf,
            column: SortColumn.stockist,
            flex: 2,
          ),
          _header(
            title: TTexts.uiTextCoverage,
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
                        color: TColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: TSizes.v15,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: TColors.white.withOpacity(.8),
                          fontSize: TSizes.v11,
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: selected ? (ascending ? 0 : 0.5) : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color:
                      selected ? TColors.white : TColors.white.withOpacity(.35),
                  size: TSizes.v18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
