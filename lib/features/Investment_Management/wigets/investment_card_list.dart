import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/investment_request_controller.dart';
import 'investment_card.dart';
import 'investment_empty.dart';


class InvestmentRequestCardList
    extends GetView<InvestmentRequestController> {
  const InvestmentRequestCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.investmentRequests.isEmpty) {
        return const InvestmentEmpty();
      }

      return LayoutBuilder(
        builder: (context, constraints) {
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

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.investmentRequests.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: ratio,
            ),
            itemBuilder: (_, index) {
              return InvestmentRequestCard(
                request: controller.investmentRequests[index],
              );
            },
          );
        },
      );
    });
  }
}