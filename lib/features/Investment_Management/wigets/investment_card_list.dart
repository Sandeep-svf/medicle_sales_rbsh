import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/investment_request_controller.dart';
import '../screen/add_investment_screen.dart';
import 'investment_card.dart';
import 'investment_empty.dart';

class InvestmentRequestCardList extends GetView<InvestmentRequestController> {
  const InvestmentRequestCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return LayoutBuilder(
        builder: (context, constraints) {
          final requests = controller.investmentRequests;
          final width = constraints.maxWidth;

          int crossAxisCount = 1;
          double ratio = .95;

          if (width >= 1200) {
            crossAxisCount = 3;
            ratio = .95;
          } else if (width >= 700) {
            crossAxisCount = 2;
            ratio = .92;
          }

          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: requests.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: constraints.maxHeight,
                        child: const InvestmentEmpty(),
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: requests.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: ratio,
                    ),
                    itemBuilder: (_, index) {
                      final request = requests[index];

                      return InvestmentRequestCard(
                        request: request,
                        onEdit: request.canEdit
                            ? () async {
                                final successMessage = await Get.to<String>(
                                  () => AddInvestmentScreen(request: request),
                                );

                                if (successMessage != null) {
                                  await controller.refreshData();
                                  Get.snackbar(
                                    "Success",
                                    successMessage,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            : null,
                      );
                    },
                  ),
          );
        },
      );
    });
  }
}
