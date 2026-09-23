import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../../controller/add_investment_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class DoctorDetailsCard extends StatelessWidget {
  const DoctorDetailsCard({super.key});

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
                  TTexts.uiTextDoctorDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                ),
                const SizedBox(height: TSizes.v20),
                if (isWide)
                  Row(
                    children: [
                      Expanded(
                        child: _buildDoctorName(controller),
                      ),
                      const SizedBox(width: TSizes.v20),
                      Expanded(
                        child: _textField(
                          controller: controller.areaHQController,
                          label: TTexts.uiTextAreaHQ,
                          hint: "Area & Headquarters",
                          readOnly: true,
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildDoctorName(controller),
                  const SizedBox(height: TSizes.v16),
                  _textField(
                    controller: controller.areaHQController,
                    label: TTexts.uiTextAreaHQ,
                    hint: "Area & Headquarters",
                    readOnly: true,
                  ),
                ],
                const SizedBox(height: TSizes.v16),
                if (isWide)
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          controller: controller.qualificationController,
                          label: TTexts.uiTextQualification,
                          hint: "Qualification",
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: TSizes.v20),
                      Expanded(
                        child: _textField(
                          controller: controller.productSuggestedController,
                          label: TTexts.uiTextProductSuggested,
                          hint: "Eg. Cardiac Range",
                        ),
                      ),
                    ],
                  )
                else ...[
                  _textField(
                    controller: controller.qualificationController,
                    label: TTexts.uiTextQualification,
                    hint: "Qualification",
                    readOnly: true,
                  ),
                  const SizedBox(height: TSizes.v16),
                  _textField(
                    controller: controller.productSuggestedController,
                    label: TTexts.uiTextProductSuggested,
                    hint: "Eg. Cardiac Range",
                  ),
                ],
                const SizedBox(height: TSizes.v16),
                _textField(
                  controller: controller.monthlyExpectedSalesController,
                  label: TTexts.uiTextMonthlyExpectedSales,
                  hint: "Expected Sales",
                  keyboardType: TextInputType.number,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDoctorName(AddInvestmentController controller) {
    return Obx(() {
      return TextFormField(
        initialValue: controller.selectedDoctorName.value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: TTexts.uiTextDoctorName,
          hintText: TTexts.uiTextSelectDoctor,
          filled: true,
          fillColor: TColors.materialGrey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: TColors.materialGrey300,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: (value) {
        if (!readOnly && (value == null || value.trim().isEmpty)) {
          return "Required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: readOnly ? TColors.materialGrey100 : TColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: TColors.materialGrey300),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
