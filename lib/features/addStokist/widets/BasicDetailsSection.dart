import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../model/headoffice.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

// adjust if needed

class BasicDetailsSection extends StatelessWidget {
  final TextEditingController firmName;
  final TextEditingController businessName;
  final String? selectedHeadOfficeId;
  final List<HeadOffice1> offices;
  final ValueChanged<String?> onHeadOfficeChanged;
  final TextEditingController gstNumber;
  final TextEditingController drugLicenceNumber;
  final TextEditingController panNumber;
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
    required this.drugLicenceNumber,
    required this.panNumber,
    super.key,
  });

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: TSizes.v18,
              fontWeight: FontWeight.bold,
              color: TColors.primary),
        ),
      );

  Widget _requiredField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text,
      int maxLines = 1,
      Function(String)? onChanged}) {
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
        const SizedBox(height: TSizes.v8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: TTexts.uiTextHeadOffice_523ae239,
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
            validator: (value) => value == null || value.isEmpty
                ? 'Please select a head office'
                : null,
          ),
        ),
        const SizedBox(height: TSizes.v8),
        _requiredField(gstNumber, 'GST Number'),
        const SizedBox(height: TSizes.v8),
        _requiredField(panNumber, ' PAN Number'),
        const SizedBox(height: TSizes.v8),
        _requiredField(drugLicenceNumber, 'Drug License Number'),
        const SizedBox(height: TSizes.v8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: TTexts.uiTextNatureOfBusiness,
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
