import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class BankDetailsSection extends StatelessWidget {
  final TextEditingController bankName;
  final TextEditingController branch;
  final TextEditingController accountNumber;
  final TextEditingController ifscCode;
  final VoidCallback onSubmitNow;

  const BankDetailsSection({
    required this.bankName,
    required this.branch,
    required this.accountNumber,
    required this.ifscCode,
    required this.onSubmitNow,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Bank Details"),
        _requiredField(bankName, "Bank Name"),
        _requiredField(branch, "Branch"),
        _requiredField(accountNumber, "Account Number",
            inputType: TextInputType.number),
        _requiredField(ifscCode, "IFSC Code"),
        const SizedBox(height: TSizes.v12),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
            onPressed: onSubmitNow,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child:
                  Text(TTexts.submit, style: TextStyle(fontSize: TSizes.v16)),
            ),
          ),
        ),
      ],
    );
  }
}
