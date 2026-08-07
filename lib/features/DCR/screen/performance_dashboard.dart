import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import '../controller/performance_controller.dart';
import '../wigets/dashboard_header.dart';
import '../wigets/kpi_card.dart';
import '../wigets/performance_table.dart';


class PerformanceDashboard extends GetView<PerformanceController> {
  const PerformanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PerformanceController());

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        title: const Text(
          "Performance Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: TColors.primary,
        centerTitle: false,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                DashboardHeader(
                  searchController: controller.searchController,
                  onChanged: controller.search,

                  selectedFilter:
                  controller.selectedFilter.value,

                  onToday: controller.loadToday,

                  onWeekly: controller.loadWeekly,

                  onMonthly: controller.loadMonthly,

                  onCustom: () async {
                    final range =
                    await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );

                    if (range == null) return;

                    controller.loadCustom(
                      start: range.start,
                      end: range.end,
                    );
                  },

                  onSortTap: () {},

                  onExportTap: () {},
                ),

                const SizedBox(height: 24),

                /// KPI CARDS
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isLandscape ? 4 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isLandscape ? 1.55 : 1.2,
                  children: [

                    KpiCard(
                      title: "Doctors",
                      icon: Icons.medical_services,
                      scheduled: controller.totalDoctorsScheduled,
                      confirmed: controller.totalDoctorsConfirmed,
                      color: Colors.blue,
                      index: 0,
                    ),

                    KpiCard(
                      title: "Chemists",
                      icon: Icons.local_pharmacy,
                      scheduled: controller.totalChemistsScheduled,
                      confirmed: controller.totalChemistsConfirmed,
                      color: Colors.purple,
                      index: 1,
                    ),

                    KpiCard(
                      title: "Stockists",
                      icon: Icons.store,
                      scheduled: controller.totalStockistsScheduled,
                      confirmed: controller.totalStockistsConfirmed,
                      color: Colors.green,
                      index: 2,
                    ),

                    KpiCard(
                      title: "Coverage",
                      icon: Icons.trending_up,
                      scheduled: 100,
                      confirmed:
                      (controller.overallCoverage * 100).round(),
                      color: TColors.primary,
                      index: 3,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                /// TABLE
                PerformanceTable(
                  employees: controller.filteredEmployees,
                  sortColumn: controller.sortColumn.value,
                  ascending: controller.ascending.value,
                  onSort: controller.sort,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }
}