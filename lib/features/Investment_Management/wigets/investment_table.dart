import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controller/investment_request_controller.dart';
import 'investment_table_row.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentRequestTable extends GetView<InvestmentRequestController> {
  const InvestmentRequestTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final requests = controller.investmentRequests;

      return Container(
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: TColors.materialGrey200,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.pureBlack.withValues(alpha: .04),
              blurRadius: TSizes.v20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            ///===================================
            /// HEADER
            ///===================================

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: TColors.primary.withValues(alpha: .04),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: TColors.materialGrey200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: TSizes.v24,
                    backgroundColor: TColors.primary,
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: TColors.white,
                    ),
                  ),
                  const SizedBox(width: TSizes.v16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          TTexts.uiTextInvestmentRequests,
                          style: TextStyle(
                            fontSize: TSizes.v19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: TSizes.v4),
                        Text(
                          "${requests.length} Total Requests",
                          style: TextStyle(
                            color: TColors.materialGrey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TColors.materialGrey300,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.sort,
                          size: TSizes.v18,
                          color: TColors.primary,
                        ),
                        SizedBox(width: TSizes.v8),
                        Text(
                          TTexts.uiTextLatest,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            ///===================================
            /// TABLE HEADER
            ///===================================

            LayoutBuilder(
              builder: (context, constraints) {
                final landscape = constraints.maxWidth > 900;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.materialGrey100,
                    border: Border(
                      bottom: BorderSide(
                        color: TColors.materialGrey300,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 5,
                        child: Text(
                          TTexts.addDoctor,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.v15,
                          ),
                        ),
                      ),
                      if (landscape)
                        const Expanded(
                          flex: 2,
                          child: Text(
                            TTexts.uiTextPayment,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const Expanded(
                        flex: 2,
                        child: Text(
                          TTexts.amount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (landscape)
                        const Expanded(
                          flex: 2,
                          child: Text(
                            TTexts.uiTextSubmitted,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const Expanded(
                        flex: 3,
                        child: Text(
                          TTexts.uiTextStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: TSizes.v70,
                      ),
                    ],
                  ),
                );
              },
            ),

            ///===================================
            /// TABLE BODY
            ///===================================

            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                child: requests.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: constraints.maxHeight,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: TSizes.v70,
                                        color: TColors.materialGrey400,
                                      ),
                                      const SizedBox(height: TSizes.v16),
                                      const Text(
                                        TTexts.uiTextNoInvestmentRequests,
                                        style: TextStyle(
                                          fontSize: TSizes.v18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: TSizes.v8),
                                      Text(
                                        TTexts.uiTextNoInvestmentRequestsFound,
                                        style: TextStyle(
                                          color: TColors.materialGrey600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: requests.length,
                        separatorBuilder: (_, __) => Divider(
                          color: TColors.materialGrey200,
                          height: TSizes.v1,
                        ),
                        itemBuilder: (_, index) {
                          return InvestmentRequestTableRow(
                            request: requests[index],
                            index: index,
                          );
                        },
                      ),
              ),
            ),

            ///===================================
            /// FOOTER
            ///===================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: TColors.materialGrey50,
                border: Border(
                  top: BorderSide(
                    color: TColors.materialGrey200,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: TSizes.v18,
                    color: TColors.materialGrey600,
                  ),
                  const SizedBox(width: TSizes.v8),
                  Expanded(
                    child: Text(
                      "Showing ${requests.length} investment request${requests.length == 1 ? "" : "s"}",
                      style: TextStyle(
                        color: TColors.materialGrey700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "${requests.length} Record${requests.length == 1 ? "" : "s"}",
                      style: const TextStyle(
                        color: TColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
