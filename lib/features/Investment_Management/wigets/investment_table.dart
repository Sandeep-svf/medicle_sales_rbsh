import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../controller/investment_request_controller.dart';

import 'investment_table_row.dart';

class InvestmentRequestTable
    extends GetView<InvestmentRequestController> {
  const InvestmentRequestTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      final requests = controller.investmentRequests;

      return Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: Colors.grey.shade200,
          ),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withValues(alpha: .04),

              blurRadius: 20,

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

              color: Colors.grey.shade200,

            ),

          ),

        ),

        child: Row(

          children: [

            const CircleAvatar(

              radius: 24,

              backgroundColor: TColors.primary,

              child: Icon(

                Icons.account_balance_wallet_outlined,

                color: Colors.white,

              ),

            ),

            const SizedBox(width: 16),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const Text(

                    "Investment Requests",

                    style: TextStyle(

                      fontSize: 19,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height: 4),

                  Text(

                    "${requests.length} Total Requests",

                    style: TextStyle(

                      color: Colors.grey.shade600,

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

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(12),

                border: Border.all(

                  color: Colors.grey.shade300,

                ),

              ),

              child: const Row(

                children: [

                  Icon(

                    Icons.sort,

                    size: 18,

                    color: TColors.primary,

                  ),

                  SizedBox(width: 8),

                  Text(

                    "Latest",

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

      color: Colors.grey.shade100,

      border: Border(
      bottom: BorderSide(
      color: Colors.grey.shade300,
      ),
      ),

      ),

      child: Row(

      children: [

      const Expanded(
      flex: 5,
      child: Text(
      "Doctor",
      style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      ),
      ),
      ),

      if (landscape)
      const Expanded(
      flex: 2,
      child: Text(
      "Payment",
      style: TextStyle(
      fontWeight: FontWeight.bold,
      ),
      ),
      ),

      const Expanded(
      flex: 2,
      child: Text(
      "Amount",
      style: TextStyle(
      fontWeight: FontWeight.bold,
      ),
      ),
      ),

      if (landscape)
      const Expanded(
      flex: 2,
      child: Text(
      "Submitted",
      style: TextStyle(
      fontWeight: FontWeight.bold,
      ),
      ),
      ),

      const Expanded(
      flex: 3,
      child: Text(
      "Status",
      style: TextStyle(
      fontWeight: FontWeight.bold,
      ),
      ),
      ),

      const SizedBox(
      width: 70,
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
                                  size: 70,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No Investment Requests",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "No investment requests found.",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
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
                    color: Colors.grey.shade200,
                    height: 1,
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
                  color: Colors.grey.shade50,

                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
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
                      size: 18,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        "Showing ${requests.length} investment request${requests.length == 1 ? "" : "s"}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
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
