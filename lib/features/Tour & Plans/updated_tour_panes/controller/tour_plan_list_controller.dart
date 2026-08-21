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

  final RxString submittingPlanId = ''.obs;

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

  /// Create flow:
  /// - Refresh the list first so duplicate checks use latest server data.
  /// - Open next month if it already exists; otherwise open a new plan.
  /// - The details screen can then switch to any selectable future month.
  Future<void> createTourPlan() async {
    debugPrint("========== Create Tour Plan ==========");

    try {
      final latestPlans = await _service.getTourPlans();
      tourPlans.assignAll(latestPlans);
      applyFilters();

      final now = DateTime.now();
      final upcomingMonth = DateTime(now.year, now.month + 1);

      final existingPlan = tourPlans.firstWhereOrNull(
        (plan) =>
            plan.month == upcomingMonth.month &&
            plan.year == upcomingMonth.year,
      );

      if (existingPlan == null) {
        await Get.to<bool>(() => const TourPlanDetailsScreen());
      } else {
        await Get.to<bool>(
          () => TourPlanDetailsScreen(planId: existingPlan.id),
        );
      }

      // Always refresh after returning because the user may have saved a draft
      // even when the details route did not explicitly return a refresh flag.
      await refreshList();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to open Tour Plan. $e",
      );
    }
  }

  /// Submit a Draft directly from the list using its existing draft ID.
  /// No calendar validation/save call is needed here because the backend
  /// submit endpoint only requires the draft ID.
  Future<void> submitDraftFromList(TourPlanModel plan) async {
    if (!plan.isDraft || submittingPlanId.value.isNotEmpty) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Submit Tour Plan?"),
        content: Text(
          "Submit ${plan.monthName}? After submission the plan will be read-only.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.send),
            label: const Text("Submit"),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    submittingPlanId.value = plan.id;

    try {
      final success = await _service.submitDraft(plan.id);

      if (!success) {
        Get.snackbar(
          "Failed",
          "Unable to submit ${plan.monthName}.",
        );
        return;
      }

      final index = tourPlans.indexWhere((item) => item.id == plan.id);
      if (index != -1) {
        tourPlans[index] = tourPlans[index].copyWith(
          status: "Submitted",
          updatedAt: DateTime.now(),
        );
        applyFilters();
      }

      Get.snackbar(
        "Success",
        "${plan.monthName} submitted successfully.",
      );

      await refreshList();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      submittingPlanId.value = '';
    }
  }



  @override
  void onClose() {

    tourPlans.close();

    filteredPlans.close();

    submittingPlanId.close();

    searchText.close();

    selectedStatus.close();

    selectedMonth.close();

    super.onClose();
  }
}