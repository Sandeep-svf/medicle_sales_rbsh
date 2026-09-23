import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class BusinessProfileSection extends StatelessWidget {
  final TextEditingController yearsInBusiness;
  final TextEditingController areasOfOperation;
  final TextEditingController distributorships;
  final TextEditingController officeAddress;
  final VoidCallback onPickLocation;

  const BusinessProfileSection({
    required this.yearsInBusiness,
    required this.areasOfOperation,
    required this.distributorships,
    required this.officeAddress,
    required this.onPickLocation,
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
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
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
      ),
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
        _sectionTitle("Business Operations"),
        _requiredField(yearsInBusiness, "Years in Business",
            inputType: TextInputType.number),
        _textField(areasOfOperation, "Areas of Operation (comma separated)"),
        _textField(distributorships,
            "Current Pharma Distributorships (comma separated)"),
        const SizedBox(height: TSizes.v12),
        _requiredField(officeAddress, "Registered Office Address", maxLines: 2),
        const SizedBox(height: TSizes.v12),
        ElevatedButton.icon(
          onPressed: onPickLocation,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            backgroundColor: TColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: TSizes.v5,
          ),
          icon: const Icon(Icons.location_on,
              color: TColors.white, size: TSizes.v22),
          label: const Text(TTexts.uiTextSelectLocation,
              style: TextStyle(
                  fontSize: TSizes.v16,
                  fontWeight: FontWeight.bold,
                  color: TColors.white)),
        ),
      ],
    );
  }
}
