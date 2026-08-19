import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screen/tour_plan_details_screen.dart';
import '../model/tour_plan_model.dart';
import '../service/TourPlanService.dart';


class TourPlanListController extends GetxController {
  TourPlanListController();

  final TourPlanService _service = TourPlanService();

  final RxString currentStatus =
      "Draft".obs;

  ///------------------------------------------------------------
  /// Loading
  ///------------------------------------------------------------

  final RxBool isLoading = false.obs;

  final RxBool isRefreshing = false.obs;

  ///------------------------------------------------------------
  /// Data
  ///------------------------------------------------------------

  final RxList<TourPlanModel> tourPlans =
      <TourPlanModel>[].obs;

  final RxList<TourPlanModel> filteredPlans =
      <TourPlanModel>[].obs;

  ///------------------------------------------------------------
  /// Filters
  ///------------------------------------------------------------

  final RxString searchText =
      ''.obs;

  final RxString selectedStatus =
      'All'.obs;

  final Rx<DateTime?> selectedMonth =
  Rx<DateTime?>(null);

  ///------------------------------------------------------------
  /// Status List
  ///------------------------------------------------------------

  final List<String> statuses = const [

    "All",

    "Draft",

    "Submitted",

    "Approved",

    "Returned",

  ];

  @override
  void onInit() {
    super.onInit();

    loadTourPlans();
  }

  ///------------------------------------------------------------
  /// Load
  ///------------------------------------------------------------

  Future<void> loadTourPlans() async {

    isLoading.value = true;

    try {

      debugPrint("========== TourPlanListController ==========");
      debugPrint("TourPlanListControllerLoading Tour Plans...");
      debugPrint("===========================================");

      final result = await _service.getTourPlans();

      debugPrint("========== TourPlanListController ==========");
      debugPrint("TourPlanListController Total Plans : ${result.length}");

      for (final plan in result) {
        debugPrint(
            "Plan => ${plan.id} | ${plan.month}/${plan.year} | ${plan.status} | Days: ${plan.days.length}");
      }

      debugPrint("===========================================");

      tourPlans.assignAll(result);

      applyFilters();

    } catch (e, stackTrace) {

      debugPrint("TourPlanListController ========== TourPlanListController ==========");
      debugPrint("TourPlanListController Load Error : $e");
      debugPrint(stackTrace.toString());
      debugPrint("TourPlanListController ===========================================");

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }

  ///------------------------------------------------------------
  /// Refresh
  ///------------------------------------------------------------

  Future<void> refreshList() async {

    isRefreshing.value = true;

    await loadTourPlans();

    isRefreshing.value = false;
  }

  ///------------------------------------------------------------
  /// Search
  ///------------------------------------------------------------

  void onSearchChanged(
      String value,
      ) {

    searchText.value = value;

    applyFilters();
  }

  ///------------------------------------------------------------
  /// Status
  ///------------------------------------------------------------

  void changeStatus(
      String status,
      ) {

    selectedStatus.value = status;

    applyFilters();
  }

  ///------------------------------------------------------------
  /// Month
  ///------------------------------------------------------------

  void changeMonth(
      DateTime? month,
      ) {

    selectedMonth.value = month;

    applyFilters();
  }

  ///------------------------------------------------------------
  /// Clear
  ///------------------------------------------------------------

  void clearFilters() {

    searchText.value = "";

    selectedStatus.value = "All";

    selectedMonth.value = null;

    applyFilters();
  }

  ///------------------------------------------------------------
  /// Apply Filters
  ///------------------------------------------------------------

  void applyFilters() {

    List<TourPlanModel> list =
    List.from(tourPlans);

    /// Search

    if (searchText.value.trim().isNotEmpty) {

      final keyword =
      searchText.value
          .toLowerCase();

      list = list.where((plan) {

        return

          plan.monthName
              .toLowerCase()
              .contains(keyword)

              ||

              plan.status
                  .toLowerCase()
                  .contains(keyword);

      }).toList();
    }

    /// Status

    if (selectedStatus.value != "All") {

      list = list.where((plan) {

        return

          plan.status ==
              selectedStatus.value;

      }).toList();
    }

    /// Month

    if (selectedMonth.value != null) {

      list = list.where((plan) {

        return

          plan.month ==
              selectedMonth.value!.month

              &&

              plan.year ==
                  selectedMonth.value!.year;

      }).toList();
    }

    /// Latest first

    list.sort(

          (a, b) =>

          b.updatedAt.compareTo(
            a.updatedAt,
          ),

    );

    filteredPlans.assignAll(list);
  }

  ///------------------------------------------------------------
  /// Helpers
  ///------------------------------------------------------------

  bool get hasData =>
      filteredPlans.isNotEmpty;

  bool get isEmpty =>

      !isLoading.value &&

          filteredPlans.isEmpty;

  int get totalPlans =>
      filteredPlans.length;

  ///------------------------------------------------------------
  /// Navigation
  ///------------------------------------------------------------

  Future<void> openDetails(TourPlanModel plan) async {

    debugPrint("========== TourPlanListController ==========");
    debugPrint("TourPlanListController Action      : Open Details");
    debugPrint("TourPlanListController Plan ID     : ${plan.id}");
    debugPrint("TourPlanListController Month       : ${plan.month}");
    debugPrint("TourPlanListController Year        : ${plan.year}");
    debugPrint("TourPlanListController Status      : ${plan.status}");
    debugPrint("TourPlanListController Days Count  : ${plan.days.length}");
    debugPrint("===========================================");

    final shouldRefresh = await Get.to<bool>(
          () => TourPlanDetailsScreen(
        planId: plan.id,
      ),
    );

    if (shouldRefresh == true) {

      debugPrint("Refreshing Tour Plan List...");

      await refreshList();
    }
  }

  /// old one no plan show if exist
  /*void createTourPlan() {

    debugPrint("Create Tour Plan Clicked");

    Get.to(
          () => const TourPlanDetailsScreen(),
    );
  }*/

  /// new one show plans if exist while create
  void createTourPlan() {
    debugPrint("========== Create Tour Plan ==========");

    final now = DateTime.now();

    // Upcoming / planning month
    final DateTime upcomingMonth = now.month == 12
        ? DateTime(now.year + 1, 1)
        : DateTime(now.year, now.month + 1);

    debugPrint(
      "Upcoming Month : ${upcomingMonth.month}/${upcomingMonth.year}",
    );

    // Check if a Tour Plan already exists for the upcoming month
    TourPlanModel? existingPlan;

    for (final plan in tourPlans) {
      if (plan.month == upcomingMonth.month &&
          plan.year == upcomingMonth.year) {
        existingPlan = plan;
        break;
      }
    }

    // ---------------------------------------------------------
    // No existing plan
    // ---------------------------------------------------------

    if (existingPlan == null) {
      debugPrint("No Tour Plan found for upcoming month.");
      debugPrint("Opening NEW Tour Plan.");

      Get.to(
            () => const TourPlanDetailsScreen(),
      );

      return;
    }

    // ---------------------------------------------------------
    // Existing plan found
    // ---------------------------------------------------------

    debugPrint("Existing Tour Plan found.");
    debugPrint("Plan ID     : ${existingPlan.id}");
    debugPrint("Month       : ${existingPlan.month}/${existingPlan.year}");
    debugPrint("Status      : ${existingPlan.status}");
    debugPrint("Days        : ${existingPlan.days.length}");

    Get.to(
          () => TourPlanDetailsScreen(
        planId: existingPlan!.id,
      ),
    );
  }



  @override
  void onClose() {

    tourPlans.close();

    filteredPlans.close();

    searchText.close();

    selectedStatus.close();

    selectedMonth.close();

    super.onClose();
  }
}