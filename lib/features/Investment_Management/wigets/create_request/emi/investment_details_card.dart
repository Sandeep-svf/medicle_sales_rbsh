import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../../utils/constants/colors.dart';
import '../../../controller/add_investment_controller.dart';

class BankDetailsCard extends StatelessWidget {
  const BankDetailsCard({super.key});

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
                  "Bank Details",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color: TColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// Account Number
                TextFormField(
                  controller:
                  controller.emiAccountNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Account Number is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Account Number",
                    hintText: "123456789012",
                    prefixIcon:
                    const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (isWide)
                  Row(
                    children: [

                      Expanded(
                        child: TextFormField(
                          controller:
                          controller.emiIfscController,
                          textCapitalization:
                          TextCapitalization.characters,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return "IFSC is required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "IFSC Code",
                            hintText: "SBIN0001234",
                            prefixIcon:
                            const Icon(Icons.code),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: TextFormField(
                          controller:
                          controller
                              .emiAccountHolderController,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return "Account Holder Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Account Holder Name",
                            hintText: "Dr. Rajesh Kumar",
                            prefixIcon:
                            const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                    ],
                  )
                else ...[
                  TextFormField(
                    controller:
                    controller.emiIfscController,
                    textCapitalization:
                    TextCapitalization.characters,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "IFSC is required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "IFSC Code",
                      hintText: "SBIN0001234",
                      prefixIcon: const Icon(Icons.code),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller:
                    controller
                        .emiAccountHolderController,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Account Holder Name";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Account Holder Name",
                      hintText: "Dr. Rajesh Kumar",
                      prefixIcon:
                      const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
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