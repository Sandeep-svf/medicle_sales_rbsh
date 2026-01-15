// lib/screens/pharma_distributor_form/widgets/contact_details_section.dart
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';

class ContactDetailsSection extends StatelessWidget {
  final TextEditingController contactPerson;
  final TextEditingController designation;
  final TextEditingController mobileNumber;
  final TextEditingController emailAddress;
  final TextEditingController website;

  const ContactDetailsSection({
    required this.contactPerson,
    required this.designation,
    required this.mobileNumber,
    required this.emailAddress,
    required this.website,
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

        _sectionTitle("Contact Information"),
        _requiredField(contactPerson, "Contact Person"),
        _textField(designation, "Designation"),
        _requiredField(mobileNumber, "Mobile Number", inputType: TextInputType.phone),
        _requiredField(emailAddress, "Email Address", inputType: TextInputType.emailAddress),
        _textField(website, "Website"),
      ],
    );
  }
}
