import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

import '../../controllers/doctor_offline_controller.dart';

class DoctorFilterBar extends StatelessWidget {
  const DoctorFilterBar({
    super.key,
    required this.controller,
    required this.searchController,
  });

  final DoctorOfflineController controller;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final dropdownWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - TSizes.md * 2) / 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              onChanged: controller.setSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Search doctors',
                hintText: 'Name, clinic, specialty, location',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.query.search.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          searchController.clear();
                          controller.setSearch('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                  borderSide:
                      const BorderSide(color: TColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: TSizes.md),
            Wrap(
              spacing: TSizes.md,
              runSpacing: TSizes.sm,
              children: [
                SizedBox(
                  width: dropdownWidth,
                  child: _FilterDropdown(
                    label: 'Priority',
                    allLabel: 'All priorities',
                    value: controller.query.priority,
                    options: controller.priorityOptions,
                    onChanged: controller.setPriority,
                  ),
                ),
                SizedBox(
                  width: dropdownWidth,
                  child: _FilterDropdown(
                    label: 'Head office',
                    allLabel: 'All head offices',
                    value: controller.query.headOfficeId,
                    options: controller.headOfficeOptions,
                    onChanged: controller.setHeadOffice,
                  ),
                ),
                SizedBox(
                  width: dropdownWidth,
                  child: _FilterDropdown(
                    label: 'Area',
                    allLabel: 'All areas',
                    value: controller.query.areaId,
                    options: controller.areaOptions,
                    onChanged: controller.setArea,
                  ),
                ),
              ],
            ),
            if (controller.query.priority != null ||
                controller.query.headOfficeId != null ||
                controller.query.areaId != null) ...[
              const SizedBox(height: TSizes.sm),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: const Text('Clear filters'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.allLabel,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  static const String _allValue = '__all__';

  final String label;
  final String allLabel;
  final String? value;
  final List<DoctorFilterOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final availableValues = options.map((option) => option.value).toSet();
    final selected =
        value != null && availableValues.contains(value) ? value : _allValue;
    return DropdownButtonFormField<String>(
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        ),
      ),
      items: [
        DropdownMenuItem(value: _allValue, child: Text(allLabel)),
        ...options.map(
          (option) => DropdownMenuItem(
            value: option.value,
            child: Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (selectedValue) {
        onChanged(selectedValue == _allValue ? null : selectedValue);
      },
    );
  }
}
