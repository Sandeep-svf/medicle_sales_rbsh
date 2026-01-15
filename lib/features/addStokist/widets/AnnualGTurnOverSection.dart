/*
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

class AnnualTurnoverSection extends StatefulWidget {
  final List<Map<String, dynamic>> turnovers;
  final Function(List<Map<String, dynamic>>) onChanged;

  const AnnualTurnoverSection({
    super.key,
    required this.turnovers,
    required this.onChanged,
  });

  @override
  State<AnnualTurnoverSection> createState() => _AnnualTurnoverSectionState();
}

class _AnnualTurnoverSectionState extends State<AnnualTurnoverSection> {
  late List<Map<String, dynamic>> _localTurnovers;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _localTurnovers = List<Map<String, dynamic>>.from(widget.turnovers);
    if (_localTurnovers.isEmpty) {
      _localTurnovers.addAll([
        {"year": currentYear, "amount": 0},
        {"year": currentYear - 1, "amount": 0},
        {"year": currentYear - 2, "amount": 0},
      ]);
    }
  }

  void _updateEntry(int index, String key, dynamic value) {
    setState(() {
      _localTurnovers[index][key] = value;
      widget.onChanged(_localTurnovers);
    });
  }

  void _addNewEntry() {
    final currentYear = DateTime.now().year;
    setState(() {
      _localTurnovers.add({"year": currentYear, "amount": 0});
      widget.onChanged(_localTurnovers);
    });
  }

  void _removeEntry(int index) {
    if (_localTurnovers.length <= 3) return; // minimum 3
    setState(() {
      _localTurnovers.removeAt(index);
      widget.onChanged(_localTurnovers);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final List<int> yearOptions = List.generate(10, (i) => currentYear - i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ..._localTurnovers.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: yearOptions.contains(item["year"]) ? item["year"] : null,
                    decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
                    items: yearOptions
                        .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) _updateEntry(index, "year", value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: item["amount"].toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder()),
                    onChanged: (value) {
                      _updateEntry(index, "amount", int.tryParse(value) ?? 0);
                    },
                  ),
                ),
                if (index >= 3)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEntry(index),
                  )
              ],
            ),
          );
        }).toList(),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _addNewEntry,
            icon: const Icon(Icons.add_circle, color: TColors.primary),
            label: const Text("Add More", style: TextStyle(color: TColors.primary)),
          ),
        ),
      ],
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';

class AnnualTurnoverSection extends StatefulWidget {
  final List<Map<String, dynamic>> turnovers;
  final Function(List<Map<String, dynamic>>) onChanged;

  const AnnualTurnoverSection({
    super.key,
    required this.turnovers,
    required this.onChanged,
  });

  @override
  State<AnnualTurnoverSection> createState() => _AnnualTurnoverSectionState();
}

class _AnnualTurnoverSectionState extends State<AnnualTurnoverSection> {
  late List<Map<String, dynamic>> _localTurnovers;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _localTurnovers = List<Map<String, dynamic>>.from(widget.turnovers);

    // Default initialization (if empty)
    if (_localTurnovers.isEmpty) {
      _localTurnovers.addAll([
        {"year": currentYear, "amount": 0},
        {"year": currentYear - 1, "amount": 0},
        {"year": currentYear - 2, "amount": 0},
      ]);
    }
  }

  void _updateEntry(int index, String key, dynamic value) {
    setState(() {
      _localTurnovers[index][key] = value;
      widget.onChanged(_localTurnovers);
    });
  }

  // --- FIX IS HERE ---
  void _addNewEntry() {
    int nextYear;

    if (_localTurnovers.isEmpty) {
      nextYear = DateTime.now().year;
    } else {
      // 1. Get all years currently in the list
      final years = _localTurnovers.map((e) => e["year"] as int).toList();

      // 2. Find the smallest year (e.g. if list is 2026, 2025, 2024 -> smallest is 2024)
      final minYear = years.reduce((curr, next) => curr < next ? curr : next);

      // 3. Set the new year to smallest - 1
      nextYear = minYear - 1;
    }

    setState(() {
      _localTurnovers.add({"year": nextYear, "amount": 0});
      widget.onChanged(_localTurnovers);
    });
  }

  void _removeEntry(int index) {
    if (_localTurnovers.length <= 3) return; // minimum 3
    setState(() {
      _localTurnovers.removeAt(index);
      widget.onChanged(_localTurnovers);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    // I increased this to 20 years so older years don't crash the dropdown
    final List<int> yearOptions = List.generate(20, (i) => currentYear - i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ..._localTurnovers.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    // Safety check: ensure the year exists in options, otherwise null (or add it)
                    value: yearOptions.contains(item["year"]) ? item["year"] : null,
                    decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
                    items: yearOptions
                        .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) _updateEntry(index, "year", value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    // Key is important so Flutter knows which row is which when deleting/adding
                    key: ValueKey(item['year']),
                    initialValue: item["amount"] == 0 ? '' : item["amount"].toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder()),
                    onChanged: (value) {
                      _updateEntry(index, "amount", int.tryParse(value) ?? 0);
                    },
                  ),
                ),
                if (index >= 3)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEntry(index),
                  )
              ],
            ),
          );
        }).toList(), // No 'toList' needed if using spread operator inside children, but fine here

        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _addNewEntry,
            icon: const Icon(Icons.add_circle, color: TColors.primary),
            label: const Text("Add More", style: TextStyle(color: TColors.primary)),
          ),
        ),
      ],
    );
  }
}