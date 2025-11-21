// lib/screens/pharma_distributor_form/widgets/basic_details_section.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../model/headoffice.dart';
// adjust if needed

class BasicDetailsSection extends StatelessWidget {
  final TextEditingController firmName;
  final TextEditingController businessName;
  final String? selectedHeadOfficeId;
  final List<HeadOffice1> offices;
  final ValueChanged<String?> onHeadOfficeChanged;
  final TextEditingController gstNumber;
  final String? selectedBusinessType;
  final List<String> businessTypes;
  final ValueChanged<String?> onBusinessTypeChanged;

  const BasicDetailsSection({
    required this.firmName,
    required this.businessName,
    required this.selectedHeadOfficeId,
    required this.offices,
    required this.onHeadOfficeChanged,
    required this.gstNumber,
    required this.selectedBusinessType,
    required this.businessTypes,
    required this.onBusinessTypeChanged,
    super.key,
  });

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.primary),
    ),
  );

  Widget _requiredField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: "$label *",
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged ?? (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Applicant Details"),
        _requiredField(firmName, "Firm Name", onChanged: (_) {}),
        _requiredField(businessName, "Registered Business Name"),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Head Office *",
              border: OutlineInputBorder(),
            ),
            value: selectedHeadOfficeId,
            items: offices.map((office) {
              return DropdownMenuItem<String>(
                value: office.id,
                child: Text(office.name),
              );
            }).toList(),
            onChanged: onHeadOfficeChanged,
            validator: (value) => value == null || value.isEmpty ? 'Please select a head office' : null,
          ),
        ),
        const SizedBox(height: 8),
        _requiredField(gstNumber, 'GST Number'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nature of Business",
          ),
          value: selectedBusinessType,
          items: businessTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: onBusinessTypeChanged,
        ),
      ],
    );
  }
}
