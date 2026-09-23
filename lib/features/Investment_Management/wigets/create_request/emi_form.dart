import 'package:flutter/material.dart';

import 'emi/doctor_details_card.dart';
import 'emi/investment_details_card.dart';
import 'emi/bank_details_card.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class EmiForm extends StatelessWidget {
  const EmiForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Doctor Details
        DoctorDetailsCard(),

        const SizedBox(height: TSizes.v20),

        /// Investment Details
        InvestmentDetailsCard(),

        const SizedBox(height: TSizes.v20),

        /// Bank Details
        BankDetailsCard(),
      ],
    );
  }
}
