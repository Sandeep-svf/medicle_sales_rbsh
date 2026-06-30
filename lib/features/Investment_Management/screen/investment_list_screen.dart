import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../controller/investment_request_controller.dart';
import '../wigets/investment_card_list.dart';
import '../wigets/investment_header.dart';

import '../wigets/investment_table.dart';
import 'add_investment_screen.dart';

class InvestmentListScreen extends StatelessWidget {
  InvestmentListScreen({super.key});

  final InvestmentRequestController controller =
  Get.put(InvestmentRequestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TColors.primary,

        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        label: const Text(
          "New Request",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        onPressed: () {
          Get.to(() => AddInvestmentScreen());
        },
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Obx(
                () => Column(
              children: [

                InvestmentHeader(
                  table: controller.tableView.value,
                  onToggle: controller.toggleView,
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: controller.isLoading.value
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : controller.errorMessage.value.isNotEmpty
                      ? Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                      : controller.tableView.value
                      ? const InvestmentRequestTable()
                      : const InvestmentRequestCardList(),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}