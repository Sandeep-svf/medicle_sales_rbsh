import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../model/area_model.dart';

/// Uses registered API areas only. Selection is owned by the beat screen.
class BeatAreaTable extends StatefulWidget {
  const BeatAreaTable(
      {super.key,
      required this.areas,
      required this.selectedIds,
      required this.onSelection,
      required this.onDetails,
      required this.onCreate,
      required this.onClear,
      required this.busy,
      required this.editing});

  final List<AreaModel> areas;
  final Set<String> selectedIds;
  final void Function(Set<String> ids, bool selected) onSelection;
  final ValueChanged<AreaModel> onDetails;
  final VoidCallback onCreate;
  final VoidCallback onClear;
  final bool busy;
  final bool editing;

  @override
  State<BeatAreaTable> createState() => _BeatAreaTableState();
}

class _BeatAreaTableState extends State<BeatAreaTable> {
  String _query = '';
  bool _onlySelected = false;
  int _page = 0;
  static const _pageSize = 15;

  @override
  Widget build(BuildContext context) {
    final areas = widget.areas
        .where((area) => area.id.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.postOffice.compareTo(b.postOffice));
    final filtered = areas
        .where((area) =>
            (!_onlySelected || widget.selectedIds.contains(area.id)) &&
            '${area.postOffice} ${area.pincode} ${area.id}'
                .toLowerCase()
                .contains(_query))
        .toList();
    final pages = (filtered.length / _pageSize).ceil();
    final page = pages == 0 ? 0 : _page.clamp(0, pages - 1);
    final rows = filtered.skip(page * _pageSize).take(_pageSize).toList();
    final selected =
        areas.where((area) => widget.selectedIds.contains(area.id)).toList();
    final filteredIds = filtered.map((area) => area.id).toSet();
    final selectedInFilter =
        filteredIds.intersection(widget.selectedIds).length;
    return Column(children: [
      Expanded(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Build your beat',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: TColors.textPrimary,
                                fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                        'Select registered post office areas, review coverage, then name your beat and choose its color.',
                        style: TextStyle(color: TColors.textSecondary)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      Chip(label: Text('${areas.length} registered areas')),
                      Chip(
                          backgroundColor: TColors.successBg,
                          label: Text('${selected.length} selected')),
                      Chip(
                          label: Text(
                              '${selected.fold<int>(0, (sum, a) => sum + a.doctorCount)} doctors')),
                      Chip(
                          label: Text(
                              '${selected.fold<int>(0, (sum, a) => sum + a.chemistCount)} chemists')),
                      Chip(
                          label: Text(
                              '${selected.fold<int>(0, (sum, a) => sum + a.stockistCount)} stockists')),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                        onChanged: (value) => setState(() {
                              _query = value.trim().toLowerCase();
                              _page = 0;
                            }),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search post office, pincode or area ID',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilterChip(
                              label: const Text('Selected only'),
                              selected: _onlySelected,
                              onSelected: (value) => setState(() {
                                    _onlySelected = value;
                                    _page = 0;
                                  })),
                          TextButton.icon(
                              icon: const Icon(Icons.select_all),
                              label: Text(
                                  'Select all ${filtered.length} matching'),
                              onPressed: widget.busy || filtered.isEmpty
                                  ? null
                                  : () =>
                                      widget.onSelection(filteredIds, true)),
                          TextButton(
                              onPressed: widget.busy || selectedInFilter == 0
                                  ? null
                                  : () =>
                                      widget.onSelection(filteredIds, false),
                              child: const Text('Deselect matching')),
                        ]),
                    if (selected.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Wrap(spacing: 6, runSpacing: 6, children: [
                            for (final area in selected)
                              InputChip(
                                  backgroundColor: TColors.successBg,
                                  label: Text(
                                      '${area.postOffice} (${area.pincode})'),
                                  onDeleted: widget.busy
                                      ? null
                                      : () =>
                                          widget.onSelection({area.id}, false)),
                          ])),
                    Card(
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                                showCheckboxColumn: true,
                                columnSpacing: 24,
                                headingRowColor: const WidgetStatePropertyAll(
                                    TColors.primary_shade50),
                                onSelectAll: widget.busy
                                    ? null
                                    : (value) => widget.onSelection(
                                        filteredIds, value ?? false),
                                columns: const [
                                  DataColumn(label: Text('Post office')),
                                  DataColumn(label: Text('Pincode')),
                                  DataColumn(
                                      label: Text('Doctors'), numeric: true),
                                  DataColumn(
                                      label: Text('Chemists'), numeric: true),
                                  DataColumn(
                                      label: Text('Stockists'), numeric: true),
                                  DataColumn(label: Text('Area details')),
                                ],
                                rows: [
                                  for (final area in rows)
                                    DataRow(
                                        selected: widget.selectedIds
                                            .contains(area.id),
                                        color:
                                            widget.selectedIds.contains(area.id)
                                                ? const WidgetStatePropertyAll(
                                                    TColors.successBg)
                                                : null,
                                        onSelectChanged: widget.busy
                                            ? null
                                            : (value) => widget.onSelection(
                                                {area.id}, value ?? false),
                                        cells: [
                                          DataCell(SizedBox(
                                              width: 220,
                                              child: Text(
                                                  area.postOffice.isEmpty
                                                      ? 'Unnamed post office'
                                                      : area.postOffice))),
                                          DataCell(Text(area.pincode)),
                                          DataCell(Text('${area.doctorCount}')),
                                          DataCell(
                                              Text('${area.chemistCount}')),
                                          DataCell(
                                              Text('${area.stockistCount}')),
                                          DataCell(TextButton.icon(
                                              onPressed: () =>
                                                  widget.onDetails(area),
                                              icon: const Icon(
                                                  Icons.info_outline,
                                                  size: 18),
                                              label:
                                                  const Text('View details'))),
                                        ]),
                                ]))),
                    if (filtered.isEmpty)
                      const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                              'No registered areas match your selection.')),
                    Row(children: [
                      Expanded(
                          child: Text(filtered.isEmpty
                              ? '0 areas'
                              : '${page * _pageSize + 1}–${page * _pageSize + rows.length} of ${filtered.length} areas')),
                      IconButton(
                          tooltip: 'Previous page',
                          onPressed: page == 0
                              ? null
                              : () => setState(() => _page = page - 1),
                          icon: const Icon(Icons.chevron_left)),
                      Text('${pages == 0 ? 0 : page + 1} / $pages'),
                      IconButton(
                          tooltip: 'Next page',
                          onPressed: page + 1 >= pages
                              ? null
                              : () => setState(() => _page = page + 1),
                          icon: const Icon(Icons.chevron_right)),
                    ]),
                  ]))),
      SafeArea(
          top: false,
          child: Container(
              color: TColors.white,
              padding: const EdgeInsets.all(12),
              child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${selected.length} areas selected',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                        onPressed: widget.busy || selected.isEmpty
                            ? null
                            : widget.onClear,
                        child: const Text('Clear selection')),
                    FilledButton.icon(
                        onPressed: widget.busy || selected.isEmpty
                            ? null
                            : widget.onCreate,
                        icon: const Icon(Icons.add),
                        label: Text(widget.editing
                            ? 'Continue editing'
                            : 'Create beat')),
                  ]))),
    ]);
  }
}
