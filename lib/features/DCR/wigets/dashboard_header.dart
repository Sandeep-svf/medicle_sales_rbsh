import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../enum/performance_filter_type.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

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
            fontSize: TSizes.v28,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),

        const SizedBox(height: TSizes.v6),

        Text(
          "Monitor field force performance",
          style: TextStyle(
            color: TColors.textSecondary.withOpacity(.8),
            fontSize: TSizes.v15,
          ),
        ),

        const SizedBox(height: TSizes.v20),

        if (isLandscape)
          Row(
            children: [
              Expanded(child: _searchBox()),
              const SizedBox(width: TSizes.v12),
              _filterChip(
                "Today",
                PerformanceFilterType.today,
                onToday,
              ),
              const SizedBox(width: TSizes.v8),
              _filterChip(
                "Weekly",
                PerformanceFilterType.weekly,
                onWeekly,
              ),
              const SizedBox(width: TSizes.v8),
              _filterChip(
                "Monthly",
                PerformanceFilterType.monthly,
                onMonthly,
              ),
              const SizedBox(width: TSizes.v8),
              _filterChip(
                "Custom",
                PerformanceFilterType.custom,
                onCustom,
              ),
              const SizedBox(width: TSizes.v10),
              _actionButton(
                icon: Icons.sort,
                label: "Sort",
                onTap: onSortTap,
              ),
              const SizedBox(width: TSizes.v10),
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
              const SizedBox(height: TSizes.v12),
              Row(
                children: [
                  Wrap(
                    spacing: TSizes.v8,
                    runSpacing: TSizes.v8,
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
      height: TSizes.v52,
      decoration: BoxDecoration(
        color: TColors.white,
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
      height: TSizes.v48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: TSizes.v0,
          backgroundColor: TColors.primary,
          foregroundColor: TColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: TSizes.v20),
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
      width: TSizes.v90,
      height: TSizes.v40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(90, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: selected ? TColors.primary : TColors.white,
          foregroundColor: selected ? TColors.white : TColors.primary,
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
              fontSize: TSizes.v13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
