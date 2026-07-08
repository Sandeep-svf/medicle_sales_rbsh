import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../../utils/constants/colors.dart';
import '../../../controller/add_investment_controller.dart';

class DoctorDetailsCard extends StatelessWidget {
  const DoctorDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddInvestmentController>();

    return Card(
      elevation: 1,
      color: Colors.white,
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
                  "Doctor Details",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),

                const SizedBox(height: 20),

                if (isWide)
                  Row(
                    children: [

                      Expanded(
                        child: _buildDoctorName(controller),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: _textField(
                          controller: controller.areaHQController,
                          label: "Area & HQ",
                          hint: "Area & Headquarters",
                          readOnly: true,
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildDoctorName(controller),
                  const SizedBox(height: 16),
                  _textField(
                    controller: controller.areaHQController,
                    label: "Area & HQ",
                    hint: "Area & Headquarters",
                    readOnly: true,
                  ),
                ],

                const SizedBox(height: 16),

                if (isWide)
                  Row(
                    children: [

                      Expanded(
                        child: _textField(
                          controller: controller.qualificationController,
                          label: "Qualification",
                          hint: "Qualification",
                          readOnly: true,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: _textField(
                          controller:
                          controller.productSuggestedController,
                          label: "Product Suggested",
                          hint: "Eg. Cardiac Range",
                        ),
                      ),
                    ],
                  )
                else ...[
                  _textField(
                    controller: controller.qualificationController,
                    label: "Qualification",
                    hint: "Qualification",
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _textField(
                    controller:
                    controller.productSuggestedController,
                    label: "Product Suggested",
                    hint: "Eg. Cardiac Range",
                  ),
                ],

                const SizedBox(height: 16),

                _textField(
                  controller:
                  controller.monthlyExpectedSalesController,
                  label: "Monthly Expected Sales",
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
          labelText: "Doctor Name",
          hintText: "Select Doctor",
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
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
        if (!readOnly &&
            (value == null || value.trim().isEmpty)) {
          return "Required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor:
        readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
          BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}