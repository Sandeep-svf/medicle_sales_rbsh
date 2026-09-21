import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../../../doctor_offline/doctor_offline_module.dart';
import '../models/visitSalesData.dart';
import '../repository/pending_visit_repository.dart';
import '../repository/pending_schedule_repository.dart';
import '../repository/visit_cache_repository.dart';
import '../models/pending_schedule_model.dart';

enum VisitDateFilter {
  today,
  last7Days,
  last15Days,
  custom,
}

class VisitListController with ChangeNotifier {
  final AuthManager authManager = AuthManager();
  final PendingVisitRepository _pendingRepository = PendingVisitRepository();
  final PendingScheduleRepository _scheduleRepository =
      PendingScheduleRepository();

  final VisitCacheRepository _cacheRepository = VisitCacheRepository();

  bool _offlineMode = false;

  bool get offlineMode => _offlineMode;

  Timer? _refreshTimer;

  final RxSet<String> pendingVisits = <String>{}.obs;

  List<VisitSalesLogModel> _visitList = [];
  String? userId;
  bool _isLoading = false;

  List<VisitSalesLogModel> get salesList => _visitList;
  bool get isLoading => _isLoading;

  final String fetchApiUrl = THttpHelper.baseUrl;
  VisitDateFilter _currentFilter = VisitDateFilter.today;
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;

  @override
  void dispose() {
    _refreshTimer?.cancel();

    super.dispose();
  }

  Future<void> setOfflineMode(bool value) async {
    if (_offlineMode == value) return;

    _offlineMode = value;

    if (_offlineMode) {
      _stopAutoRefresh();
    }

    await fetchSalesList(
      filter: _currentFilter,
      startDate: _currentStartDate,
      endDate: _currentEndDate,
    );

    if (!_offlineMode) {
      _startAutoRefresh();
    }

    notifyListeners();
  }

  Future<void> loadPendingVisits() async {
    final visits = await _pendingRepository.getPendingVisits();

    pendingVisits.clear();

    pendingVisits.addAll(
      visits.map((e) => e.visitId),
    );
    debugPrint(
      'VisitListController: pending visit rows=${visits.length}; '
      'ids=${visits.map((visit) => '${visit.visitId}(server=${visit.serverVisitId}, schedule=${visit.localScheduleId})').join(', ')}',
    );
  }

  Future<void> refreshPendingVisits() async {
    await loadPendingVisits();
    notifyListeners();
  }

  String _getCacheKey({
    required VisitDateFilter filter,
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    switch (filter) {
      case VisitDateFilter.today:
        return "${userId}_today";

      case VisitDateFilter.last7Days:
        return "${userId}_last7days";

      case VisitDateFilter.last15Days:
        return "${userId}_last15days";

      case VisitDateFilter.custom:
        if (startDate != null && endDate != null) {
          final formatter = DateFormat('yyyy-MM-dd');

          return "${userId}_custom_${formatter.format(startDate)}_${formatter.format(endDate)}";
        }

        return "${userId}_today";
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) async {
        if (_offlineMode) return;

        debugPrint("VisitListController: Auto Refresh");

        await fetchSalesList(
          filter: _currentFilter,
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        );
      },
    );
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> fetchSalesList({
    VisitDateFilter filter = VisitDateFilter.today,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    _currentFilter = filter;
    _currentStartDate = startDate;
    _currentEndDate = endDate;

    userId ??= await authManager.getUserId();

    if (userId == null || userId!.isEmpty) {
      _visitList = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    final cacheKey = _getCacheKey(
      filter: filter,
      userId: userId!,
      startDate: startDate,
      endDate: endDate,
    );

    // Show the last known list immediately. A network refresh must not block
    // visits that are already available on the device.
    final cachedJson = await _cacheRepository.get(cacheKey);
    if (cachedJson != null && cachedJson.isNotEmpty) {
      _visitList = VisitSalesLogModel.listFromRawJson(cachedJson);
      await _mergeLocalSchedules();
      await loadPendingVisits();
      notifyListeners();
    }

    if (offlineMode) {
      debugPrint("VisitListController: OFFLINE MODE - Loading cached visits");

      if (cachedJson != null) {
        _visitList = VisitSalesLogModel.listFromRawJson(cachedJson);

        await _mergeLocalSchedules();

        await loadPendingVisits();

        debugPrint(
            "VisitListController: Loaded ${_visitList.length} cached visits");
      } else {
        debugPrint("VisitListController: No cached visits found");

        _visitList = [];
        await _mergeLocalSchedules();
      }

      _isLoading = false;
      notifyListeners();

      return;
    }

    try {
      debugPrint("VisitListController: ======================================");
      debugPrint("VisitListController: fetchSalesList() started");
      debugPrint("VisitListController: Selected Filter = $filter");

      debugPrint("VisitListController: User ID = $userId");

      if (userId == null || userId!.isEmpty) {
        debugPrint("VisitListController: User ID is null or empty");

        _visitList = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      String apiUrl = "$fetchApiUrl/doctor-visits/user/$userId";

      String queryParams = "";

      switch (filter) {
        case VisitDateFilter.today:
          queryParams = "?range=today";
          debugPrint("VisitListController: Applying TODAY filter");
          break;

        case VisitDateFilter.last7Days:
          queryParams = "?range=last7days";
          debugPrint("VisitListController: Applying LAST 7 DAYS filter");
          break;

        case VisitDateFilter.last15Days:
          queryParams = "?range=last15days";
          debugPrint("VisitListController: Applying LAST 15 DAYS filter");
          break;

        case VisitDateFilter.custom:
          if (startDate != null && endDate != null) {
            final formatter = DateFormat('yyyy-MM-dd');

            final start = formatter.format(startDate);

            final end = formatter.format(endDate);

            queryParams = "?startDate=$start&endDate=$end";

            debugPrint("VisitListController: Applying CUSTOM filter");
            debugPrint("VisitListController: Start Date = $start");
            debugPrint("VisitListController: End Date = $end");
          } else {
            debugPrint(
                "VisitListController: Custom dates missing. Falling back to TODAY");

            queryParams = "?range=today";
          }
          break;
      }

      final fullUrl = "$apiUrl$queryParams";

      debugPrint("VisitListController: API URL = $fullUrl");

      final token = await authManager.getAuthToken();
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Accept': 'application/json',
          if (token?.isNotEmpty == true) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      debugPrint("VisitListController: Status Code = ${response.statusCode}");

      debugPrint("VisitListController: Raw Response = ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        debugPrint("VisitListController: Records Received = ${data.length}");

        _visitList = data
            .map(
              (item) => VisitSalesLogModel.fromJson(item),
            )
            .toList();

        await _cacheRepository.save(
          cacheKey: cacheKey,
          json: response.body,
        );

        await _mergeLocalSchedules();

        await loadPendingVisits();

        if (!_offlineMode && _refreshTimer == null) {
          _startAutoRefresh();
        }

        debugPrint(
            "VisitListController: Records Parsed = ${_visitList.length}");

        if (_visitList.isNotEmpty) {
          debugPrint("VisitListController: First Record Loaded Successfully");
        }
      } else {
        debugPrint("VisitListController: API Failed");

        throw Exception(
          "Failed to fetch sales logs. Status Code: ${response.statusCode}",
        );
      }
    } catch (e, stackTrace) {
      debugPrint("VisitListController: Exception = $e");

      debugPrint("VisitListController: StackTrace = $stackTrace");

      debugPrint("VisitListController: Trying to load cached data...");

      if (cachedJson != null) {
        _visitList = VisitSalesLogModel.listFromRawJson(cachedJson);

        await _mergeLocalSchedules();

        await loadPendingVisits();

        debugPrint(
            "VisitListController: Loaded ${_visitList.length} visits from cache.");
      } else {
        debugPrint("VisitListController: No cached data found.");

        _visitList = [];
        await _mergeLocalSchedules();
      }
    } finally {
      _isLoading = false;

      debugPrint("VisitListController: Loading Finished");

      debugPrint("VisitListController: Final Count = ${_visitList.length}");

      debugPrint("VisitListController: ======================================");

      notifyListeners();
    }
  }

  Future<void> _mergeLocalSchedules() async {
    final currentUserId = userId;
    if (currentUserId == null || currentUserId.isEmpty) return;
    final schedules = await _scheduleRepository.getForUser(currentUserId);
    if (schedules.isEmpty) return;

    final cachedDoctorAreas = await _cachedDoctorAreas(
      schedules.where((schedule) => schedule.areaId == null),
    );

    final existingIds = _visitList.map((visit) => visit.id).toSet();
    final local = <VisitSalesLogModel>[];
    for (final schedule in schedules) {
      final id = schedule.serverVisitId ?? schedule.localId;
      if (existingIds.contains(id)) continue;
      if (!_matchesDateFilter(schedule)) continue;
      local.add(
        _toLocalVisit(
          schedule,
          areaId: schedule.areaId ??
              cachedDoctorAreas[schedule.doctorLocalId] ??
              (schedule.serverDoctorId == null
                  ? null
                  : cachedDoctorAreas[schedule.serverDoctorId!]),
        ),
      );
    }
    if (local.isNotEmpty) _visitList = [...local, ..._visitList];
  }

  bool _matchesDateFilter(PendingScheduleModel schedule) {
    final date = DateTime.tryParse(schedule.date);
    if (date == null) return true;
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    switch (_currentFilter) {
      case VisitDateFilter.today:
        return day == todayOnly;
      case VisitDateFilter.last7Days:
        return !day.isBefore(todayOnly.subtract(const Duration(days: 6))) &&
            !day.isAfter(todayOnly);
      case VisitDateFilter.last15Days:
        return !day.isBefore(todayOnly.subtract(const Duration(days: 14))) &&
            !day.isAfter(todayOnly);
      case VisitDateFilter.custom:
        final start = _currentStartDate == null
            ? null
            : DateTime(_currentStartDate!.year, _currentStartDate!.month,
                _currentStartDate!.day);
        final end = _currentEndDate == null
            ? null
            : DateTime(_currentEndDate!.year, _currentEndDate!.month,
                _currentEndDate!.day);
        return start == null || end == null
            ? day == todayOnly
            : !day.isBefore(start) && !day.isAfter(end);
    }
  }

  Future<Map<String, String>> _cachedDoctorAreas(
      Iterable<PendingScheduleModel> unresolved) async {
    if (!unresolved.any((schedule) => schedule.areaId == null)) {
      return const <String, String>{};
    }

    DoctorOfflineModule? module;
    try {
      module = await DoctorOfflineModule.acquire(accountId: userId!);
      final areas = <String, String>{};
      for (final doctor in module.controller.allDoctors) {
        final areaId = doctor.areaId?.trim();
        if (areaId == null || areaId.isEmpty) continue;
        areas[doctor.localId] = areaId;
        if (doctor.clientGeneratedId != null) {
          areas[doctor.clientGeneratedId!] = areaId;
        }
        if (doctor.serverId != null) areas[doctor.serverId!] = areaId;
      }
      return areas;
    } catch (_) {
      return const <String, String>{};
    } finally {
      if (module != null) await module.dispose();
    }
  }

  VisitSalesLogModel _toLocalVisit(
    PendingScheduleModel schedule, {
    String? areaId,
  }) {
    final serverOrLocalDoctorId =
        schedule.serverDoctorId ?? schedule.doctorLocalId;
    return VisitSalesLogModel(
      id: schedule.serverVisitId ?? schedule.localId,
      doctorId: serverOrLocalDoctorId,
      userId: schedule.userId,
      dateStr: schedule.date,
      date: DateTime.tryParse(schedule.date),
      notes: schedule.notes,
      confirmed: false,
      localScheduleId: schedule.localId,
      schedulePending: !schedule.isUploaded,
      scheduleSyncError: schedule.lastError,
      doctor: VisitDoctor(
        id: serverOrLocalDoctorId,
        name: schedule.doctorName,
        areaId: areaId,
        latitude: schedule.doctorLatitude,
        longitude: schedule.doctorLongitude,
      ),
    );
  }
}
