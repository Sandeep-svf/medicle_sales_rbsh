import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../../controller/add_investment_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class BankDetailsCard extends StatelessWidget {
  const BankDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddInvestmentController>();

    return Card(
      elevation: TSizes.v1,
      color: TColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TTexts.uiTextBankDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: TSizes.v20),

                /// Account Number
                TextFormField(
                  controller: controller.emiAccountNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Account Number is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: TTexts.uiTextAccountNumber,
                    hintText: TTexts.uiText123456789012,
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.v16),

                if (isWide)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.emiIfscController,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "IFSC is required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: TTexts.uiTextIFSCCode,
                            hintText: TTexts.uiTextSBIN0001234,
                            prefixIcon: const Icon(Icons.code),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: TSizes.v20),
                      Expanded(
                        child: TextFormField(
                          controller: controller.emiAccountHolderController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Account Holder Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: TTexts.uiTextAccountHolderName,
                            hintText: TTexts.uiTextDrRajeshKumar,
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else ...[
                  TextFormField(
                    controller: controller.emiIfscController,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "IFSC is required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: TTexts.uiTextIFSCCode,
                      hintText: TTexts.uiTextSBIN0001234,
                      prefixIcon: const Icon(Icons.code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.v16),
                  TextFormField(
                    controller: controller.emiAccountHolderController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Account Holder Name";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: TTexts.uiTextAccountHolderName,
                      hintText: TTexts.uiTextDrRajeshKumar,
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
