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
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Request",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: _openCreateRequest,
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
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: Center(
                    child: Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return controller.tableView.value
        ? const InvestmentRequestTable()
        : const InvestmentRequestCardList();
  }

  Future<void> _openCreateRequest() async {
    final successMessage = await Get.to<String>(() => AddInvestmentScreen());

    if (successMessage != null) {
      await controller.refreshData();
      Get.snackbar(
        "Success",
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
