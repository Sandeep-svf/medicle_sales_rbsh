import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../../controller/add_investment_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentDetailsCard extends StatelessWidget {
  const InvestmentDetailsCard({super.key});

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
                  TTexts.uiTextInvestmentDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: TSizes.v20),

                ///-------------------------------
                /// Investment Type + Amount
                ///-------------------------------
                if (isWide)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: "EMI",
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: TTexts.uiTextInvestmentType,
                            filled: true,
                            fillColor: TColors.materialGrey100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: TSizes.v20),
                      Expanded(
                        child: TextFormField(
                          controller: controller.emiAmountController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Amount required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: TTexts.uiTextAmount,
                            hintText: TTexts.uiText50000,
                            prefixIcon: const Icon(
                              Icons.currency_rupee,
                            ),
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
                    initialValue: "EMI",
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: TTexts.uiTextInvestmentType,
                      filled: true,
                      fillColor: TColors.materialGrey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.v16),
                  TextFormField(
                    controller: controller.emiAmountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Amount required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: TTexts.uiTextAmount,
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: TSizes.v16),

                ///-------------------------------
                /// Date + Months
                ///-------------------------------
                if (isWide)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.emiDateController,
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Select date";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: TTexts.date,
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2100),
                            );

                            if (date != null) {
                              controller.emiDateController.text =
                                  "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: TSizes.v20),
                      Expanded(
                        child: TextFormField(
                          controller: controller.emiMonthsController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: TTexts.uiTextEMIMonths,
                            hintText: TTexts.uiText12,
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
                    controller: controller.emiDateController,
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Select date";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: TTexts.date,
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2100),
                      );

                      if (date != null) {
                        controller.emiDateController.text =
                            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.v16),
                  TextFormField(
                    controller: controller.emiMonthsController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: TTexts.uiTextEMIMonths,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: TSizes.v16),

                ///-------------------------------
                /// Remarks
                ///-------------------------------
                TextFormField(
                  controller: controller.emiRemarksController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: TTexts.uiTextRemarks,
                    hintText: TTexts.uiTextEnterInvestmentRemarks,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
