import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/performance_filter_type.dart';
import '../model/dcr_visit_model.dart';

import '../model/performance_model.dart';

import '../service/performance_service.dart';
import '../wigets/table_header.dart';

class PerformanceController extends GetxController {
  PerformanceController();

  //--------------------------------------------------
  // SERVICE
  //--------------------------------------------------

  final PerformanceService service = PerformanceService.instance;

  //--------------------------------------------------
  // FILTER
  //--------------------------------------------------

  final Rx<PerformanceFilterType> selectedFilter =
      PerformanceFilterType.today.obs;

  final Rxn<DateTime> startDate =
  Rxn<DateTime>();

  final Rxn<DateTime> endDate =
  Rxn<DateTime>();
  //--------------------------------------------------
  // SEARCH
  //--------------------------------------------------

  final TextEditingController searchController =
  TextEditingController();

  //--------------------------------------------------
  // DATA
  //--------------------------------------------------

  final RxList<PerformanceModel> employees =
      <PerformanceModel>[].obs;

  final RxList<PerformanceModel> filteredEmployees =
      <PerformanceModel>[].obs;

  //--------------------------------------------------
  // LOADING
  //--------------------------------------------------

  final RxBool isLoading = false.obs;

  //--------------------------------------------------
  // SORT
  //--------------------------------------------------

  final Rx<SortColumn> sortColumn =
      SortColumn.employee.obs;

  final RxBool ascending = true.obs;

  //--------------------------------------------------
  // INIT
  //--------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    loadDashboard();

    searchController.addListener(() {
      search(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  //--------------------------------------------------
  // LOAD DASHBOARD
  //--------------------------------------------------

  Future<void> loadDashboard() async{
    try {
      if (isLoading.value) return;

      isLoading.value = true;

      final response = await service.getDashboard(
        filter: selectedFilter.value.apiValue,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      final groupedEmployees = groupVisits(
        response.visits,
      );

      employees
        ..clear()
        ..assignAll(groupedEmployees);

      filteredEmployees
        ..clear()
        ..assignAll(groupedEmployees);

      searchController.clear();
    } catch (e) {
      debugPrint(
        "Performance Dashboard Error : $e",
      );

      Get.snackbar(
        "Dashboard",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadToday() async {
    selectedFilter.value = PerformanceFilterType.today;

    startDate.value = null;
    endDate.value = null;

    await loadDashboard();
  }

  Future<void> loadWeekly() async {
    selectedFilter.value = PerformanceFilterType.weekly;

    startDate.value = null;
    endDate.value = null;

    await loadDashboard();
  }

  Future<void> loadMonthly() async {
    selectedFilter.value = PerformanceFilterType.monthly;

    startDate.value = null;
    endDate.value = null;

    await loadDashboard();
  }

  Future<void> loadCustom({
    required DateTime start,
    required DateTime end,
  }) async {

    selectedFilter.value =
        PerformanceFilterType.custom;

    startDate.value = start;

    endDate.value = end;

    await loadDashboard();
  }

  //--------------------------------------------------
  // SEARCH
  //--------------------------------------------------

  void search(String value) {
    if (value.trim().isEmpty) {
      filteredEmployees.assignAll(employees);
      return;
    }

    final keyword = value.toLowerCase();

    filteredEmployees.assignAll(
      employees.where((e) {
        return e.name.toLowerCase().contains(keyword) ||
            e.employeeCode.toLowerCase().contains(keyword);
      }).toList(),
    );
  }

  //--------------------------------------------------
  // SORT
  //--------------------------------------------------

  void sort(SortColumn column) {
    if (sortColumn.value == column) {
      ascending.toggle();
    } else {
      sortColumn.value = column;
      ascending.value = true;
    }

    filteredEmployees.sort((a, b) {
      int result = 0;

      switch (column) {
        case SortColumn.employee:
          result = a.name.compareTo(b.name);
          break;

        case SortColumn.doctor:
          result = a.doctorConfirmed.compareTo(
            b.doctorConfirmed,
          );
          break;

        case SortColumn.chemist:
          result = a.chemistConfirmed.compareTo(
            b.chemistConfirmed,
          );
          break;

        case SortColumn.stockist:
          result = a.stockistConfirmed.compareTo(
            b.stockistConfirmed,
          );
          break;

        case SortColumn.coverage:
          result = a.overallCoverage.compareTo(
            b.overallCoverage,
          );
          break;
      }

      return ascending.value ? result : -result;
    });

    filteredEmployees.refresh();
  }

  //--------------------------------------------------
  // KPI
  //--------------------------------------------------

  int get totalDoctorsScheduled =>
      employees.fold(0, (a, b) => a + b.doctorScheduled);

  int get totalDoctorsConfirmed =>
      employees.fold(0, (a, b) => a + b.doctorConfirmed);

  int get totalChemistsScheduled =>
      employees.fold(0, (a, b) => a + b.chemistScheduled);

  int get totalChemistsConfirmed =>
      employees.fold(0, (a, b) => a + b.chemistConfirmed);

  int get totalStockistsScheduled =>
      employees.fold(0, (a, b) => a + b.stockistScheduled);

  int get totalStockistsConfirmed =>
      employees.fold(0, (a, b) => a + b.stockistConfirmed);

  double get overallCoverage {
    final scheduled =
        totalDoctorsScheduled +
            totalChemistsScheduled +
            totalStockistsScheduled;

    final confirmed =
        totalDoctorsConfirmed +
            totalChemistsConfirmed +
            totalStockistsConfirmed;

    if (scheduled == 0) return 0;

    return confirmed / scheduled;
  }

  //--------------------------------------------------
  // REFRESH
  //--------------------------------------------------

  Future<void> refreshData() async {
    await loadDashboard();
  }

  //--------------------------------------------------
  // GROUP VISITS
  //--------------------------------------------------

  List<PerformanceModel> groupVisits(
      List<DcrVisitModel> visits) {

    final Map<String, Map<String, dynamic>> grouped = {};

    for (final visit in visits) {

      final user = visit.user;

      if (user == null) continue;

      grouped.putIfAbsent(user.id, () {
        return {
          "id": user.id,
          "employeeCode": user.employeeCode,
          "name": user.name,
          "doctorScheduled": 0,
          "doctorConfirmed": 0,
          "chemistScheduled": 0,
          "chemistConfirmed": 0,
          "stockistScheduled": 0,
          "stockistConfirmed": 0,
        };
      });

      final item = grouped[user.id]!;

      switch (visit.visitType.toLowerCase()) {

        case "doctor":

          item["doctorScheduled"] =
              (item["doctorScheduled"] as int) + 1;

          if (visit.confirmed) {
            item["doctorConfirmed"] =
                (item["doctorConfirmed"] as int) + 1;
          }

          break;

        case "chemist":

          item["chemistScheduled"] =
              (item["chemistScheduled"] as int) + 1;

          if (visit.confirmed) {
            item["chemistConfirmed"] =
                (item["chemistConfirmed"] as int) + 1;
          }

          break;

        case "stockist":

          item["stockistScheduled"] =
              (item["stockistScheduled"] as int) + 1;

          if (visit.confirmed) {
            item["stockistConfirmed"] =
                (item["stockistConfirmed"] as int) + 1;
          }

          break;
      }
    }

    return grouped.values.map((e) {

      return PerformanceModel(
        id: e["id"],
        employeeCode: e["employeeCode"],
        name: e["name"],
        doctorScheduled: e["doctorScheduled"],
        doctorConfirmed: e["doctorConfirmed"],
        chemistScheduled: e["chemistScheduled"],
        chemistConfirmed: e["chemistConfirmed"],
        stockistScheduled: e["stockistScheduled"],
        stockistConfirmed: e["stockistConfirmed"],
      );

    }).toList();
  }
}