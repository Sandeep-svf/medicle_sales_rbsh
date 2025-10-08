import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constants/colors.dart';

class PtrPtsCalculatorScreen extends StatefulWidget {
  const PtrPtsCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<PtrPtsCalculatorScreen> createState() => _PtrPtsCalculatorScreenState();
}

class _PtrPtsCalculatorScreenState extends State<PtrPtsCalculatorScreen> {
  final _mrpCtrl = TextEditingController();           // keep empty by default
  final _retailerCtrl = TextEditingController(text: '20');  // default 20
  final _stockistCtrl = TextEditingController(text: '10');  // default 10

  double _ptr = 0.0;   // always-visible, start at 0.00
  double _pts = 0.0;   // always-visible, start at 0.00

  final List<int> gstOptions = [5, 12, 18, 28];
  int _selectedGst = 5;   // default 5%

  @override
  void initState() {
    super.initState();
    for (final c in [_mrpCtrl, _retailerCtrl, _stockistCtrl]) {
      c.addListener(_recalculate);
    }
    // run once in case defaults already compute something
    _recalculate();
  }

  @override
  void dispose() {
    _mrpCtrl.dispose();
    _retailerCtrl.dispose();
    _stockistCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    final mrp = double.tryParse(_mrpCtrl.text);
    final retailer = double.tryParse(_retailerCtrl.text);
    final stockist = double.tryParse(_stockistCtrl.text);
    final gst = _selectedGst.toDouble();

    // If any field (besides MRP being empty) is invalid → show 0.00
    if (retailer == null || stockist == null) {
      setState(() {
        _ptr = 0.0;
        _pts = 0.0;
      });
      return;
    }

    if (mrp == null) {
      // No MRP yet → keep zeroes visible
      setState(() {
        _ptr = 0.0;
        _pts = 0.0;
      });
      return;
    }

    final ptr = (mrp - (mrp * (retailer / 100))) / (1 + (gst / 100));
    final pts = ptr - (ptr * (stockist / 100));

    setState(() {
      _ptr = double.parse(ptr.toStringAsFixed(2));
      _pts = double.parse(pts.toStringAsFixed(2));
    });
  }

  void _reset() {
    _mrpCtrl.clear();
    _retailerCtrl.text = '20';
    _stockistCtrl.text = '10';
    setState(() {
      _selectedGst = 5;
      _ptr = 0.0;
      _pts = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = Colors.blue.shade700;
    final orange = Colors.orange.shade700;

    return Scaffold(
      appBar: AppBar(

        actions: [
          IconButton(
            tooltip: 'Reset All',
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormulaCard(themeBlue: themeBlue),
                  const SizedBox(height: 18),

                  _InputField(
                    controller: _mrpCtrl,
                    label: 'MRP',
                    hint: 'e.g., 1230',
                    suffix: '₹',
                  ),
                  const SizedBox(height: 14),

                  // GST DROPDOWN (default 5%)
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'GST',
                      labelStyle: TextStyle(color: Colors.grey.shade800),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedGst,
                        isExpanded: true,
                        items: gstOptions
                            .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text('$g %'),
                        ))
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => _selectedGst = val);
                          _recalculate();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _InputField(
                    controller: _retailerCtrl,
                    label: 'Retailer Margin',
                    hint: 'Default 20',
                    suffix: '%',
                  ),
                  const SizedBox(height: 14),

                  _InputField(
                    controller: _stockistCtrl,
                    label: 'Stockist Margin',
                    hint: 'Default 10',
                    suffix: '%',
                  ),
                  const SizedBox(height: 22),

                  // Always-visible RESULTS (start at 0.00)
                  Row(
                    children: [
                      Expanded(
                        child: _ResultCard(label: 'PTR', value: _ptr, color: orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ResultCard(label: 'PTS', value: _pts, color: orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// FORMULA CARD
class _FormulaCard extends StatelessWidget {
  const _FormulaCard({required this.themeBlue});
  final Color themeBlue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.info_outline, color: themeBlue),
            const SizedBox(width: 8),
            Text(
              'How PTR & PTS are calculated',
              style: TextStyle(
                color: themeBlue,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          const Text(
            'PTR = (MRP − (MRP × RetailerMargin/100)) ÷ (1 + GST/100)\n'
                'PTS = PTR − (PTR × StockistMargin/100)',
            style: TextStyle(color: Colors.black87, height: 1.4),
          ),
        ]),
      ),
    );
  }
}

/// INPUT FIELD
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String suffix;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        labelStyle: TextStyle(color: Colors.grey.shade800),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade100,
        enabledBorder: border,
        focusedBorder:
        border.copyWith(borderSide: BorderSide(color: TColors.primary, width: 1.2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}

/// RESULT CARD (always visible; shows 0.00 initially)
class _ResultCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ResultCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
