// lib/screens/pharma_distributor_form/widgets/facilities_section.dart
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';

class FacilitiesSection extends StatelessWidget {
  final bool warehouseFacility;
  final bool coldStorageAvailable;
  final TextEditingController storageSize;
  final TextEditingController salesReps;
  final ValueChanged<bool> onWarehouseChanged;
  final ValueChanged<bool> onColdStorageChanged;

  const FacilitiesSection({
    required this.warehouseFacility,
    required this.coldStorageAvailable,
    required this.storageSize,
    required this.salesReps,
    required this.onWarehouseChanged,
    required this.onColdStorageChanged,
    super.key,
  });

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.primary),
    ),
  );

  Widget _checkbox(String title, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      activeColor: TColors.primary,
      onChanged: (val) => onChanged(val ?? false),
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Facilities"),
        _checkbox("Warehouse Facility", warehouseFacility, onWarehouseChanged),
        _textField(storageSize, "Storage Facility Size (in sqft)", inputType: TextInputType.number),
        _checkbox("Cold Storage Available", coldStorageAvailable, onColdStorageChanged),
        _textField(salesReps, "No. of Sales Representatives", inputType: TextInputType.number),
      ],
    );
  }
}
