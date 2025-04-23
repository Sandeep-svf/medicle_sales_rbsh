import 'package:flutter/material.dart';


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
  final List<Map<String, dynamic>> _localTurnovers = [];
  int? _selectedYear;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localTurnovers.addAll(widget.turnovers);
  }

  void _pickYear() async {
    final now = DateTime.now();
    final pickedYear = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      helpText: 'Select Year',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (pickedYear != null) {
      setState(() {
        _selectedYear = pickedYear.year;
      });
    }
  }

  void _addTurnoverEntry() {
    if (_selectedYear == null || _amountController.text.isEmpty) return;

    final amount = int.tryParse(_amountController.text);
    if (amount == null) return;

    final newEntry = {"year": _selectedYear, "amount": amount};

    setState(() {
      _localTurnovers.add(newEntry);
      _selectedYear = null;
      _amountController.clear();
      widget.onChanged(_localTurnovers); // Notify parent
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _localTurnovers.removeAt(index);
      widget.onChanged(_localTurnovers); // Notify parent
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Annual Turnover", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _pickYear,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedYear != null ? _selectedYear.toString() : 'Pick Year',
                    style: TextStyle(color: _selectedYear != null ? Colors.black : Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addTurnoverEntry,
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              tooltip: 'Add Entry',
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _localTurnovers.length,
          itemBuilder: (context, index) {
            final entry = _localTurnovers[index];
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text("Year: ${entry['year']}"),
              subtitle: Text("₹ ${entry['amount']}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeEntry(index),
              ),
            );
          },
        ),
      ],
    );
  }
}
