import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/Tour%20&%20Plans/updated_tour_panes/Screen/tour_plan_table.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

import '../controller/tour_plan_list_controller.dart';
import '../wigets/status_chip.dart';


class TourPlanListScreen extends StatelessWidget {
  const TourPlanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TourPlanListController(),
    );

    return Scaffold(
      backgroundColor: TColors.light,

      floatingActionButton: FloatingActionButton.extended(
        heroTag: "createTourPlan",
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        onPressed: controller.createTourPlan,
        icon: const Icon(Icons.add),
        label: const Text("Create Tour Plan"),
      ),

      body: SafeArea(
        child: Obx(() {

          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: TColors.primary,
              ),
            );
          }

          return RefreshIndicator(
            color: TColors.primary,
            onRefresh: controller.refreshList,
            child: LayoutBuilder(
              builder: (context, constraints) {

                final isLandscape =
                    constraints.maxWidth >= 900;

                return Column(
                  children: [

                    _buildHeader(controller),

                    _buildFilterBar(controller),

                    Expanded(

                      child: controller.isEmpty

                          ? _buildEmptyState()

                          : isLandscape

                          ? TourPlanTable(
                        plans: controller.filteredPlans,
                        onDetails: controller.openDetails,
                      )

                          : _buildMobileList(
                        controller,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }

  //-----------------------------------------------------------
  // Header
  //-----------------------------------------------------------

  Widget _buildHeader(
      TourPlanListController controller) {

    return Container(
      padding: const EdgeInsets.all(
        TSizes.lg,
      ),

      color: TColors.white,

      child: Row(
        children: [

          const Icon(
            Icons.calendar_month,
            color: TColors.primary,
            size: 32,
          ),

          const SizedBox(
            width: TSizes.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                const Text(
                  "Tour Plans",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${controller.totalPlans} Plans",
                  style: const TextStyle(
                    color:
                    TColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 280,

            child: TextField(

              onChanged:
              controller.onSearchChanged,

              decoration: InputDecoration(

                hintText:
                "Search month or status",

                prefixIcon:
                const Icon(Icons.search),

                filled: true,

                fillColor:
                TColors.softGrey,

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    TSizes.borderRadiusLg,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //-----------------------------------------------------------
  // Filters
  //-----------------------------------------------------------

  Widget _buildFilterBar(
      TourPlanListController controller) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.lg,
        vertical: TSizes.md,
      ),

      color: TColors.white,

      child: Row(
        children: [

          Expanded(
            child: DropdownButtonFormField<String>(

              value:
              controller.selectedStatus.value,

              decoration:
              const InputDecoration(
                labelText: "Status",
              ),

              items: controller.statuses

                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
                  .toList(),

              onChanged: (value) {

                if (value == null) {
                  return;
                }

                controller.changeStatus(
                  value,
                );
              },
            ),
          ),

          const SizedBox(
            width: TSizes.md,
          ),

          Expanded(
            child: OutlinedButton.icon(

              onPressed: () {

                controller.changeMonth(
                  null,
                );
              },

              icon: const Icon(
                Icons.calendar_today,
              ),

              label: Text(

                controller.selectedMonth.value ==
                    null

                    ? "All Months"

                    : "${controller.selectedMonth.value!.month}/${controller.selectedMonth.value!.year}",
              ),
            ),
          ),

          const SizedBox(
            width: TSizes.md,
          ),

          ElevatedButton.icon(

            onPressed:
            controller.clearFilters,

            icon: const Icon(
              Icons.clear,
            ),

            label: const Text(
              "Clear",
            ),
          ),
        ],
      ),
    );
  }

  //-----------------------------------------------------------
  // Portrait Cards
  //-----------------------------------------------------------

  Widget _buildMobileList(
      TourPlanListController controller) {

    return ListView.separated(

      padding:
      const EdgeInsets.all(
        TSizes.lg,
      ),

      itemCount:
      controller.filteredPlans.length,

      separatorBuilder:
          (_, __) =>
      const SizedBox(
        height: TSizes.md,
      ),

      itemBuilder: (context, index) {

        final plan =
        controller.filteredPlans[index];

        return Card(

          child: Padding(

            padding:
            const EdgeInsets.all(
              TSizes.md,
            ),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  plan.monthName,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  children: [

                    StatusChip(
                      status: plan.status,
                    ),

                    const Spacer(),

                    TextButton(
                      onPressed: () =>
                          controller.openDetails(
                            plan,
                          ),
                      child:
                      const Text("Details"),
                    ),
                  ],
                ),

                if ((plan.comments ?? "")
                    .isNotEmpty)

                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 8,
                    ),
                    child: Text(
                      plan.comments!,
                      style:
                      const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  //-----------------------------------------------------------
  // Empty
  //-----------------------------------------------------------

  Widget _buildEmptyState() {

    return Center(
      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: const [

          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: TColors.textSecondary,
          ),

          SizedBox(height: 16),

          Text(
            "No Tour Plans Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Tap 'Create Tour Plan' to start planning.",
          ),
        ],
      ),
    );
  }
}