import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../../utils/constants/colors.dart';
import '../../../controller/add_investment_controller.dart';

class InvestmentDetailsCard extends StatelessWidget {
  const InvestmentDetailsCard({super.key});

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
                  "Investment Details",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color: TColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

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
                            labelText: "Investment Type",
                            filled: true,
                            fillColor: Colors.grey.shade100,
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
                          controller.emiAmountController,
                          keyboardType:
                          TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return "Amount required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Amount (₹)",
                            hintText: "50000",
                            prefixIcon: const Icon(
                              Icons.currency_rupee,
                            ),
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
                    initialValue: "EMI",
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Investment Type",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller:
                    controller.emiAmountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Amount required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Amount (₹)",
                      prefixIcon:
                      const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                ///-------------------------------
                /// Date + Months
                ///-------------------------------
                if (isWide)
                  Row(
                    children: [

                      Expanded(
                        child: TextFormField(
                          controller:
                          controller.emiDateController,
                          readOnly: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return "Select date";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Date",
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                          onTap: () async {
                            final date =
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:
                              DateTime(2024),
                              lastDate:
                              DateTime(2100),
                            );

                            if (date != null) {
                              controller
                                  .emiDateController
                                  .text =
                              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: TextFormField(
                          controller:
                          controller.emiMonthsController,
                          keyboardType:
                          TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "EMI Months",
                            hintText: "12",
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
                    controller.emiDateController,
                    readOnly: true,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return "Select date";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Date",
                      suffixIcon:
                      const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    onTap: () async {
                      final date =
                      await showDatePicker(
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

                  const SizedBox(height: 16),

                  TextFormField(
                    controller:
                    controller.emiMonthsController,
                    keyboardType:
                    TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "EMI Months",
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                ///-------------------------------
                /// Remarks
                ///-------------------------------
                TextFormField(
                  controller: controller.emiRemarksController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Remarks",
                    hintText:
                    "Enter investment remarks",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),
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