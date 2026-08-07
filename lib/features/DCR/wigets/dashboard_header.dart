import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import '../enum/performance_filter_type.dart';

class DashboardHeader extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback? onToday;

  final VoidCallback? onWeekly;

  final VoidCallback? onMonthly;

  final VoidCallback? onCustom;

  final PerformanceFilterType selectedFilter;
  final VoidCallback? onSortTap;
  final VoidCallback? onExportTap;
  final ValueChanged<String>? onChanged;

  const DashboardHeader({
    super.key,
    required this.searchController,
    required this.selectedFilter,

    this.onToday,

    this.onWeekly,

    this.onMonthly,

    this.onCustom,
    this.onSortTap,
    this.onExportTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Title
        const Text(
          "Team Performance",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Monitor field force performance",
          style: TextStyle(
            color: TColors.textSecondary.withOpacity(.8),
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 20),

        if (isLandscape)
          Row(
            children: [

              Expanded(child: _searchBox()),

              const SizedBox(width: 12),

              _filterChip(
                "Today",
                PerformanceFilterType.today,
                onToday,
              ),

              const SizedBox(width: 8),

              _filterChip(
                "Weekly",
                PerformanceFilterType.weekly,
                onWeekly,
              ),

              const SizedBox(width: 8),

              _filterChip(
                "Monthly",
                PerformanceFilterType.monthly,
                onMonthly,
              ),

              const SizedBox(width: 8),

              _filterChip(
                "Custom",
                PerformanceFilterType.custom,
                onCustom,
              ),

              const SizedBox(width: 10),

              _actionButton(
                icon: Icons.sort,
                label: "Sort",
                onTap: onSortTap,
              ),

              const SizedBox(width: 10),

              _actionButton(
                icon: Icons.download_outlined,
                label: "Export",
                onTap: onExportTap,
              ),
            ],
          )
        else
          Column(
            children: [

              _searchBox(),

              const SizedBox(height: 12),

              Row(
                children: [

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [

                      _filterChip(
                        "Today",
                        PerformanceFilterType.today,
                        onToday,
                      ),

                      _filterChip(
                        "Weekly",
                        PerformanceFilterType.weekly,
                        onWeekly,
                      ),

                      _filterChip(
                        "Monthly",
                        PerformanceFilterType.monthly,
                        onMonthly,
                      ),

                      _filterChip(
                        "Custom",
                        PerformanceFilterType.custom,
                        onCustom,
                      ),

                      _actionButton(
                        icon: Icons.sort,
                        label: "Sort",
                        onTap: onSortTap,
                      ),

                      _actionButton(
                        icon: Icons.download_outlined,
                        label: "Export",
                        onTap: onExportTap,
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
      ],
    );
  }

  Widget _searchBox() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderSecondary),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search),
          hintText: "Search employee...",
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              searchController.clear();
              onChanged?.call("");
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: TColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }

  Widget _filterChip(
      String title,
      PerformanceFilterType type,
      VoidCallback? onTap,
      ) {
    final selected = selectedFilter == type;

    return SizedBox(
      width: 90,
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(90, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: selected ? TColors.primary : Colors.white,
          foregroundColor: selected ? Colors.white : TColors.primary,
          side: const BorderSide(color: TColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}