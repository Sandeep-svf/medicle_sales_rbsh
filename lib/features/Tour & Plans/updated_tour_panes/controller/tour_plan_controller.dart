import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';

import '../../../../utils/http/http_client.dart';
import '../../../Holiday/controller/HolidayController.dart';
import '../../../Holiday/models/Holiday.dart';

import '../DayType.dart';
import '../model/TourDay.dart';
import '../model/available_user_model.dart';
import '../model/beat_model.dart';
import '../model/tour_plan_model.dart';
import '../service/TourPlanService.dart';
import '../utils/month_selector.dart';
import '../wigets/draft_saved_dialog.dart';
import '../wigets/tour_plan_validation_dialog.dart';



class TourPlanController extends GetxController {

  final TourPlanService service =
  TourPlanService();

  final RxString currentStatus = "Draft".obs;

  bool get readOnly =>
      tourPlan.value?.status == "Submitted" ||
          tourPlan.value?.status == "Approved";

  bool get canSubmit =>
      tourPlan.value?.status == "Draft" ||
          tourPlan.value?.status == "Returned";



  /// -------------------------------------------------------
  /// Loading States
  /// -------------------------------------------------------

  final RxBool isLoading =
      false.obs;

  final RxBool isSavingDraft =
      false.obs;

  final RxBool isSubmitting =
      false.obs;

  final RxBool isReadOnly =
      false.obs;

  final RxBool hasUnsavedChanges = false.obs;

  /// -------------------------------------------------------
  /// Tour Plan
  /// -------------------------------------------------------

  final Rx<TourPlanModel?> tourPlan =
  Rx<TourPlanModel?>(null);

  final RxString draftId =
      ''.obs;

  /// -------------------------------------------------------
  /// Calendar
  /// -------------------------------------------------------

  final RxList<TourDay> monthDays =
      <TourDay>[].obs;

  final Rx<TourDay?> selectedDay =
  Rx<TourDay?>(null);

  /// Currently opened tour plan
  final Rxn<TourPlanModel> currentPlan =
  Rxn<TourPlanModel>();

  /// Remarks from ASM
  final RxString remarks = "".obs;



  /// -------------------------------------------------------
  /// Masters
  /// -------------------------------------------------------

  final RxList<String> dayTypes =
      <String>[].obs;

  final RxList<String>
  collaborationStatus =
      <String>[].obs;

  final RxList<BeatModel> beats =
      <BeatModel>[].obs;

  final RxList<AvailableUserModel>
  availableUsers =
      <AvailableUserModel>[].obs;

  DateTime? _availableUsersDate;

  /// -------------------------------------------------------
  /// Month
  /// -------------------------------------------------------

  final Rx<DateTime> selectedMonth =
      _defaultPlanningMonth().obs;

  static DateTime
  _defaultPlanningMonth() {
    final now = DateTime.now();

    if (now.month == 12) {
      return DateTime(
        now.year + 1,
        1,
      );
    }

    return DateTime(
      now.year,
      now.month + 1,
    );
  }

  String get monthTitle {
    const months = [

      '',

      'January',

      'February',

      'March',

      'April',

      'May',

      'June',

      'July',

      'August',

      'September',

      'October',

      'November',

      'December'

    ];

    return

      "${months[selectedMonth.value.month]} "
          "${selectedMonth.value.year}";
  }

  /// -------------------------------------------------------
  /// Status
  /// -------------------------------------------------------

  bool get isDraft =>
      tourPlan.value?.status == "Draft";

  bool get isSubmitted =>
      tourPlan.value?.status == "Submitted";

  bool get isApproved =>
      tourPlan.value?.status == "Approved";

  bool get isReturned =>
      tourPlan.value?.status == "Returned";


  /// -------------------------------------------------------
  /// Editability
  /// -------------------------------------------------------

  /// New plan, Draft and Returned are editable.
  bool get canEdit {
    if (tourPlan.value == null) {
      return true;
    }

    return isDraft || isReturned;
  }


  /// -------------------------------------------------------
  /// New / Existing Plan
  /// -------------------------------------------------------

  bool get isNewTourPlan =>
      tourPlan.value == null;


  /// -------------------------------------------------------
  /// Existing plan status helpers
  /// -------------------------------------------------------

  bool get isReturnedTourPlan =>
      tourPlan.value != null &&
          tourPlan.value!.status == "Returned";

  bool get isSubmittedTourPlan =>
      tourPlan.value != null &&
          tourPlan.value!.status == "Submitted";

  bool get isApprovedTourPlan =>
      tourPlan.value != null &&
          tourPlan.value!.status == "Approved";

  bool get isDraftTourPlan =>
      tourPlan.value != null &&
          tourPlan.value!.status == "Draft";


  /// -------------------------------------------------------
  /// Current Plan Edit Mode
  /// -------------------------------------------------------

  /// New + Draft + Returned = EDIT
  /// Submitted + Approved = READ ONLY
  bool get canEditCurrentPlan {
    if (tourPlan.value == null) {
      return true;
    }

    return isDraftTourPlan ||
        isReturnedTourPlan;
  }


  /// -------------------------------------------------------
  /// View Mode
  /// -------------------------------------------------------

  bool get isViewMode =>
      !canEditCurrentPlan;



  void _syncPlanState(TourPlanModel? plan) {
    tourPlan.value = plan;
    currentStatus.value = plan?.status ?? "Draft";
    draftId.value = plan?.id ?? "";
    isReadOnly.value = plan?.isReadOnly ?? false;

    if (plan != null) {
      selectedMonth.value = DateTime(plan.year, plan.month);
    }
  }

  Future<void> loadPlanForSelectedMonth() async {
    final month = selectedMonth.value.month;
    final year = selectedMonth.value.year;

    debugPrint("==========================================");
    debugPrint("TourPlanController loadPlanForSelectedMonth");
    debugPrint("Selected Month : $month");
    debugPrint("Selected Year  : $year");
    debugPrint("==========================================");

    isLoading.value = true;

    try {
      // ----------------------------------------------------------
      // Get all existing tour plans
      // ----------------------------------------------------------

      final plans = await service.getTourPlans();

      // ----------------------------------------------------------
      // Find plan for selected month/year
      // ----------------------------------------------------------

      TourPlanModel? matchingPlan;

      for (final plan in plans) {
        if (plan.month == month &&
            plan.year == year) {
          matchingPlan = plan;
          break;
        }
      }

      // ----------------------------------------------------------
      // EXISTING PLAN FOUND
      // ----------------------------------------------------------

      if (matchingPlan != null) {
        debugPrint(
          "Existing plan found: "
              "${matchingPlan.id} | "
              "${matchingPlan.month}/${matchingPlan.year} | "
              "${matchingPlan.status}",
        );

        // Load complete details. Keep the current month intact if details fail.
        final loaded = await loadTourPlan(
          matchingPlan.id,
          showError: false,
        );
        if (!loaded) {
          throw Exception("Unable to load ${matchingPlan.monthName} details.");
        }

        return;
      }

      // ----------------------------------------------------------
      // NO PLAN FOUND
      // ----------------------------------------------------------

      debugPrint(
        "No Tour Plan found for "
            "$month/$year",
      );

      // Clear previous month's plan and reset state for a new draft.
      _syncPlanState(null);
      hasUnsavedChanges.value = false;
      selectedDay.value = null;
      availableUsers.clear();
      _availableUsersDate = null;
      monthDays.clear();

      // Create empty calendar for the selected month.
      generateCalendar();

    } catch (e, stackTrace) {

      debugPrint(
        "TourPlanController loadPlanForSelectedMonth ERROR: $e",
      );

      debugPrint(
        stackTrace.toString(),
      );

      rethrow;
    } finally {

      isLoading.value = false;
    }
  }

  ///--------------------------------------------------------------
  /// Change Planning Month
  ///--------------------------------------------------------------
  /*Future<void> changePlanningMonth(BuildContext context) async {
    if (!isNewTourPlan) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: "Select Planning Month",
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null) return;

    selectedMonth.value = DateTime(
      picked.year,
      picked.month,
    );

    selectedDay.value = null;

    generateCalendar();
  }*/

  bool validateAllDaysAssigned() {
    final List<TourDay> unassignedDays = [];

    for (final day in monthDays) {
      // Holiday is allowed.
      if (day.isHoliday) {
        continue;
      }

      // Weekly Off is allowed.
      if (day.isWeeklyOff) {
        continue;
      }

      // Every other day must have a plan.
      if (day.type == DayType.unassigned) {
        unassignedDays.add(day);
      }
    }

    // ----------------------------------------------------------
    // All working days are complete.
    // ----------------------------------------------------------

    if (unassignedDays.isEmpty) {
      return true;
    }

    // ----------------------------------------------------------
    // Show detailed validation dialog.
    // ----------------------------------------------------------

    Get.dialog(
      TourPlanValidationDialog(
        unassignedDays: unassignedDays,
      ),
      barrierDismissible: false,
    );

    return false;
  }

  Future<void> changePlanningMonth(
      BuildContext context,
      ) async {

    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) {
        return MonthSelector(
          selectedMonth: selectedMonth.value,
        );
      },
    );

    if (picked == null) {
      return;
    }

    final newMonth = DateTime(
      picked.year,
      picked.month,
    );

    // Same month selected.
    if (newMonth.year == selectedMonth.value.year &&
        newMonth.month == selectedMonth.value.month) {
      return;
    }

    if (hasUnsavedChanges.value) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Discard Unsaved Changes?"),
          content: Text(
            "You have unsaved changes in $monthTitle. "
            "Switching months will discard those changes.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Stay"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Discard & Switch"),
            ),
          ],
        ),
      );

      if (discard != true) {
        return;
      }
    }

    final previousMonth = selectedMonth.value;

    selectedMonth.value = newMonth;
    selectedDay.value = null;

    try {
      // Existing month -> load it. Missing month -> create a blank calendar.
      await loadPlanForSelectedMonth();
    } catch (e) {
      selectedMonth.value = previousMonth;
      Get.snackbar(
        "Unable to Change Month",
        "Could not load the selected month. Please try again.",
      );
    }
  }
  /// -------------------------------------------------------
  /// Init
  /// -------------------------------------------------------

  @override
  void onInit() {
    super.onInit();


  }

  Future<void> initialize({
    bool createNew = true,
  }) async {
    isLoading.value = true;

    try {
      await Future.wait([
        loadBeats(),
        loadMasterEnums(),
      ]);

      if (createNew) {
        generateCalendar();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBeats() async {
    final result = await service.getBeats();

    // Keep inactive beats available for displaying historical assignments.
    // The editor filters them out when choosing a new beat.
    beats.assignAll(result);
  }

  Future<void> loadAvailableUsers(DateTime date) async {
    _availableUsersDate = DateTime(date.year, date.month, date.day);
    availableUsers.clear();

    final result = await service.getAvailableUsers(date);

    // Ignore a slower response if the user has already selected another date.
    final requestedDate = DateTime(date.year, date.month, date.day);
    if (_availableUsersDate != requestedDate) {
      return;
    }

    availableUsers.assignAll(
      result.where((e) => e.available),
    );
  }

  Future<void> loadMasterEnums() async {
    try {
      final response =
      await THttpHelper.authGet(
        "master/enums",
      );

      if (response["success"] == true) {
        final data = response["data"];

        dayTypes.assignAll(

          List<String>.from(

            data["TourPlanDay"]["day_type"],

          ),

        );

        collaborationStatus.assignAll(

          List<String>.from(

            data["TourPlanDay"]
            ["collaboration_status"],

          ),

        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> loadTourPlan(
    String tourPlanId, {
    bool showError = true,
  }) async {

    debugPrint("========== TourPlanController ==========");
    debugPrint("TourPlanController loadTourPlan()");
    debugPrint("TourPlanController Plan Id : $tourPlanId");
    debugPrint("========================================");

    isLoading.value = true;

    try {

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Calling Details API...");
      debugPrint("========================================");

      final response = await service.getTourPlanDetails(
        tourPlanId,
      );

      if (response == null) {
        debugPrint(
          "TourPlanController API Response : NULL",
        );

        if (showError) {
          Get.snackbar(
            "Error",
            "Unable to load Tour Plan details.",
          );
        }
        return false;
      }

      if (response.year <= 0 || response.month < 1 || response.month > 12) {
        if (showError) {
          Get.snackbar(
            "Invalid Tour Plan",
            "The server returned an invalid planning month.",
          );
        }
        return false;
      }

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Response Month : ${response?.month}");
      debugPrint("TourPlanController Response Year  : ${response?.year}");

      selectedMonth.value = DateTime(
        response!.year,
        response.month,
      );

      debugPrint("TourPlanController Selected Month : ${selectedMonth.value.month}");
      debugPrint("TourPlanController Selected Year  : ${selectedMonth.value.year}");
      debugPrint("=================================");

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController API Success");
      debugPrint("TourPlanController TourPlan Id : ${response.id}");
      debugPrint("TourPlanController Status      : ${response.status}");
      debugPrint("TourPlanController Month       : ${response.month}");
      debugPrint("TourPlanController Year        : ${response.year}");
      debugPrint("TourPlanController Days Count  : ${response.days.length}");
      debugPrint("========================================");

      selectedDay.value = null;
      availableUsers.clear();
      _availableUsersDate = null;
      monthDays.clear();

      _syncPlanState(response);

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Generating Calendar...");
      debugPrint("========================================");

      generateCalendar();

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Month Days Before Populate : ${monthDays.length}");
      debugPrint("========================================");

      populateExistingDays();
      hasUnsavedChanges.value = false;

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Month Days After Populate : ${monthDays.length}");
      debugPrint("========================================");



      debugPrint("========== PLAN MODE ==========");
      debugPrint("TourPlanController New        : $isNewTourPlan");
      debugPrint("TourPlanController Returned   : $isReturnedTourPlan");
      debugPrint("TourPlanController Draft      : $isDraftTourPlan");
      debugPrint("TourPlanController Submitted  : $isSubmittedTourPlan");
      debugPrint("TourPlanController Approved   : $isApprovedTourPlan");
      debugPrint("TourPlanController Editable   : $canEditCurrentPlan");
      debugPrint("===============================");

      return true;
    } catch (e, stack) {

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController ERROR");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      debugPrint("========================================");

      if (showError) {
        Get.snackbar(
          "Error",
          "Unable to load Tour Plan details.",
        );
      }
      return false;
    } finally {

      isLoading.value = false;

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Loading Finished");
      debugPrint("========================================");
    }
  }



  Future<void> createNewTourPlan() async {
    _syncPlanState(null);
    hasUnsavedChanges.value = false;
    selectedDay.value = null;
    availableUsers.clear();
    _availableUsersDate = null;
    monthDays.clear();
    generateCalendar();
  }

  Future<void> changeMonth(DateTime month) async {
    final previousMonth = selectedMonth.value;
    selectedMonth.value = DateTime(month.year, month.month);
    selectedDay.value = null;

    try {
      await loadPlanForSelectedMonth();
    } catch (_) {
      selectedMonth.value = previousMonth;
      Get.snackbar(
        "Unable to Change Month",
        "Could not load the selected month. Please try again.",
      );
    }
  }

  void generateCalendar() {

    debugPrint("========== TourPlanController ==========");
    debugPrint("TourPlanController generateCalendar()");
    debugPrint("TourPlanController Calendar Month : ${selectedMonth.value.month}");
    debugPrint("TourPlanController Calendar Year  : ${selectedMonth.value.year}");
    debugPrint("=================================");
    final holidayController =

    Get.isRegistered<HolidayController>()

        ? Get.find<HolidayController>()

        : Get.put(
      HolidayController(),
    );

    monthDays.clear();

    final totalDays = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      0,
    ).day;

    for (
    int day = 1;
    day <= totalDays;
    day++
    ) {
      final date = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month,
        day,
      );

      /// Weekly Off

      if (date.weekday == DateTime.sunday) {
        monthDays.add(

          TourDay(

            date: date,

            type: DayType.holiday,

            holidayName: "Weekly Off",

            notes: "Sunday Off",

          ),

        );

        continue;
      }

      /// Holiday

      final Holiday? holiday =

      holidayController.holidays

          .firstWhereOrNull(

            (e) =>

        e.date.year == date.year &&

            e.date.month == date.month &&

            e.date.day == date.day,

      );

      if (holiday != null) {
        monthDays.add(

          TourDay(

            date: date,

            type: DayType.holiday,

            holidayName: holiday.title,

            notes: holiday.title,

          ),

        );

        continue;
      }

      monthDays.add(

        TourDay(

          date: date,

          type: DayType.unassigned,

        ),

      );
    }
  }

  void populateExistingDays() {

    debugPrint("========== TourPlanController ==========");
    debugPrint("TourPlanController populateExistingDays()");
    debugPrint("========================================");

    if (tourPlan.value == null) {
      debugPrint("TourPlanController tourPlan is NULL");
      return;
    }

    debugPrint(
      "TourPlanController API Days : ${tourPlan.value!.days.length}",
    );

    for (final apiDay in tourPlan.value!.days) {

      final index = monthDays.indexWhere(
            (e) =>
        e.date.year == apiDay.date.year &&
            e.date.month == apiDay.date.month &&
            e.date.day == apiDay.date.day,
      );

      debugPrint("----------------------------------------");
      debugPrint("TourPlanController API Date     : ${apiDay.date}");
      debugPrint("TourPlanController Calendar Idx : $index");
      debugPrint("TourPlanController API Type     : ${apiDay.dayType}");
      debugPrint("TourPlanController Beat Id      : ${apiDay.beatId1}");
      debugPrint("TourPlanController Beat Name    : ${apiDay.beat1?["beat_name"]}");
      debugPrint("TourPlanController Notes        : ${apiDay.notes}");

      if (index == -1) {

        debugPrint(
          "TourPlanController >>> DATE NOT FOUND",
        );

        continue;
      }

      monthDays[index] = monthDays[index].copyWith(
        // ----------------------------------------------------------
        // DAY
        // ----------------------------------------------------------

        type: mapApiDayType(
          apiDay.dayType,
        ),

        apiDayType:
        apiDay.dayType,

        // ----------------------------------------------------------
        // BACKEND IDS
        // ----------------------------------------------------------

        id:
        apiDay.id,

        tourPlanId:
        apiDay.tourPlanId,

        // ----------------------------------------------------------
        // COLLABORATION
        // ----------------------------------------------------------

        collaborationStatus:
        apiDay.collaborationStatus,

        // ----------------------------------------------------------
        // BEAT 1
        // ----------------------------------------------------------

        beatId:
        apiDay.beatId1,

        beatName:
        _getBeatName(
          apiDay.beat1,
        ),

        // ----------------------------------------------------------
        // BEAT 2
        // ----------------------------------------------------------

        beatId2:
        apiDay.beatId2,

        beatName2:
        _getBeatName(
          apiDay.beat2,
        ),

        // ----------------------------------------------------------
        // JOINT WORK
        // ----------------------------------------------------------

        jointWorkUserIds:
        List<String>.from(
          apiDay.jointWorkUserIds,
        ),

        jointWorkUserNames:
        _getJointWorkUserNames(
          apiDay.jointWorkUsers,
          apiDay.jointWorkWith,
        ),

        // ----------------------------------------------------------
        // NOTES
        // ----------------------------------------------------------

        notes:
        apiDay.notes,
      );

      debugPrint(
          "TourPlanController Updated Type = ${monthDays[index].type}"
      );

      debugPrint(
          "TourPlanController Updated Beat = ${monthDays[index].beatName}"
      );

      debugPrint(
        "TourPlanController UPDATED : ${monthDays[index]}",
      );
    }

    debugPrint("TourPlanController ========== FINAL CALENDAR ==========");

    for (final day in monthDays) {
      debugPrint(day.toString());
    }

    debugPrint("===================================");

    monthDays.refresh();
  }

  String? _getBeatName(
      Map<String, dynamic>? beat,
      ) {
    if (beat == null) {
      return null;
    }

    final name =
        beat["name"] ??
            beat["beat_name"] ??
            beat["beatName"];

    if (name == null) {
      return null;
    }

    final value = name.toString().trim();

    if (value.isEmpty) {
      return null;
    }

    return value;
  }

  List<String> _getJointWorkUserNames(
    List<Map<String, dynamic>> jointWorkUsers,
    Map<String, dynamic>? jointWorkWith,
  ) {
    String? extractName(dynamic value) {
      if (value is! Map) return null;

      final nestedUser = value["user"] ?? value["joint_work_user"];
      if (nestedUser is Map) {
        final nestedName = extractName(nestedUser);
        if (nestedName != null) return nestedName;
      }

      final name =
          value["name"] ??
          value["user_name"] ??
          value["userName"] ??
          value["full_name"] ??
          value["fullName"];

      final text = name?.toString().trim() ?? "";
      return text.isEmpty ? null : text;
    }

    // Current API shape: joint_work_users: [{...user...}, ...]
    final names = jointWorkUsers
        .map(extractName)
        .whereType<String>()
        .toList();

    if (names.isNotEmpty) {
      return names;
    }

    // Backward-compatible fallback for older jointWorkWith payloads.
    final users = jointWorkWith?["users"];
    if (users is List) {
      return users
          .map(extractName)
          .whereType<String>()
          .toList();
    }

    final singleName = extractName(jointWorkWith);
    return singleName == null ? const [] : [singleName];
  }

  void selectDay(TourDay day) {
    if (!canEditCurrentPlan || !day.isEditable) {
      return;
    }

    selectedDay.value = day;

    if (day.type == DayType.jointWork) {
      loadAvailableUsers(day.date);
    } else {
      availableUsers.clear();
      _availableUsersDate = null;
    }
  }

  void selectEditableDay(TourDay day) {

    debugPrint("========== selectEditableDay ==========");
    debugPrint("Status : ${currentStatus.value}");
    debugPrint("Editable : $canEditCurrentPlan");
    debugPrint("=======================================");

    if (!canEditCurrentPlan) {
      Get.snackbar(
        "Read Only",
        "This Tour Plan cannot be edited.",
      );
      return;
    }

    if (day.holidayName == "Weekly Off" ||
        day.type == DayType.holiday) {
      return;
    }

    selectedDay.value = day;

    if (day.type == DayType.jointWork) {
      loadAvailableUsers(day.date);
    } else {
      availableUsers.clear();
      _availableUsersDate = null;
    }
  }

  void updateDay(TourDay updatedDay,) {
    if (!canEditCurrentPlan) {
      return;
    }

    final index = monthDays.indexWhere(

          (e) =>

      e.date.year == updatedDay.date.year &&

          e.date.month == updatedDay.date.month &&

          e.date.day == updatedDay.date.day,

    );

    if (index == -1) {
      return;
    }

    monthDays[index] = updatedDay;
    hasUnsavedChanges.value = true;

    selectedDay.value = updatedDay;

    monthDays.refresh();
  }

  ///------------------------------------------------------------
  /// Validate Single Day
  ///------------------------------------------------------------

  String? validateDay(TourDay day) {

    /// Weekly Off / Holiday

    if (!day.isEditable) {
      return null;
    }

    /// Field

    if (day.type == DayType.field) {
      if (!day.hasBeat) {
        return "Please select Beat.";
      }
    }

    /// Joint Work

    if (day.type == DayType.jointWork) {
      if (!day.hasBeat) {
        return "Please select Beat.";
      }

      if (!day.hasJointUser) {
        return "Please select Joint Work user.";
      }
    }

    /// Meeting

    if (day.type == DayType.meeting) {
      if ((day.notes ?? "")
          .trim()
          .isEmpty) {
        return "Meeting remarks are required.";
      }
    }

    /// Office

    if (day.type == DayType.office) {
      if ((day.notes ?? "")
          .trim()
          .isEmpty) {
        return "Office remarks are required.";
      }
    }

    /// Transit

    if (day.type == DayType.transit) {
      if ((day.notes ?? "").trim().isEmpty) {
        return "Transit remarks are required.";
      }
    }

    /// Leave

    if (day.type == DayType.leave) {
      if ((day.notes ?? "").trim().isEmpty) {
        return "Leave remarks are required.";
      }
    }

    return null;
  }

  ///------------------------------------------------------------
  /// Validate Tour Plan
  ///------------------------------------------------------------

  bool validateTourPlan() {
    for (final day in monthDays) {
      final validation = validateDay(day);

      if (validation != null) {
        Get.snackbar(
          "Validation",
          "${day.date.day}-${day.date.month}-${day.date.year}\n$validation",
          backgroundColor: TColors.warning.withOpacity(.15),
        );

        return false;
      }
    }

    return true;
  }

  //------------------------------------------------------------
  /// Day Summary
//------------------------------------------------------------

  int get fieldCount =>
      monthDays.where((e) => e.type == DayType.field).length;

  int get jointWorkCount =>
      monthDays.where((e) => e.type == DayType.jointWork).length;

  int get meetingCount =>
      monthDays.where((e) => e.type == DayType.meeting).length;

  int get officeCount =>
      monthDays.where((e) => e.type == DayType.office).length;

  int get transitCount =>
      monthDays.where((e) => e.type == DayType.transit).length;

  int get leaveCount =>
      monthDays.where((e) => e.type == DayType.leave).length;

  int get holidayCount =>
      monthDays.where((e) => e.isHoliday && !e.isWeeklyOff).length;

  int get weeklyOffCount =>
      monthDays.where((e) => e.isWeeklyOff).length;

  ///------------------------------------------------------------
  /// UI Enum -> API
  ///------------------------------------------------------------

  String mapDayType(TourDay day) {
    switch (day.type) {

      case DayType.field:
        return "Field";

      case DayType.jointWork:
        return "Joint work";

      case DayType.meeting:
        return "Meeting";

      case DayType.office:
        return "Office";

      case DayType.transit:
        return "Transit";

      case DayType.leave:
        return "Leave";

      case DayType.holiday:

        if (day.isWeeklyOff) {
          return "Weekly off";
        }

        return "Holiday";

      case DayType.unassigned:
        throw StateError(
          "Unassigned day ${day.date.toIso8601String()} cannot be sent to the API.",
        );
    }
  }


  int get plannedDaysCount =>
      monthDays.where((e) =>
      e.type != DayType.unassigned &&
          e.type != DayType.holiday).length;

  int get workingDaysCount =>
      monthDays.where((e) =>
      e.type == DayType.field ||
          e.type == DayType.jointWork ||
          e.type == DayType.meeting ||
          e.type == DayType.office ||
          e.type == DayType.transit).length;



  ///------------------------------------------------------------
  /// Draft Body
  ///------------------------------------------------------------

  Map<String, dynamic> buildDraftBody() {
    return {

      "month": selectedMonth.value.month,

      "year": selectedMonth.value.year,

      "days":

      monthDays.map(

            (day) {
          return {

            "date":

            day.date
                .toIso8601String()
                .split("T")
                .first,

            "day_type":

            mapDayType(day),

            "beat_id_1":

            day.beatId,

            "beat_id_2":

            day.beatId2,

            "joint_work_user_ids":

            day.jointWorkUserIds,

            "notes":

            day.notes ?? "",
          };
        },
      ).toList(),
    };
  }

  ///------------------------------------------------------------
  /// Find Day
  ///------------------------------------------------------------

  TourDay? findDay(DateTime date,) {
    try {
      return monthDays.firstWhere(

            (e) =>

        e.date.year == date.year &&

            e.date.month == date.month &&

            e.date.day == date.day,

      );
    } catch (_) {
      return null;
    }
  }

  ///------------------------------------------------------------
  /// Clear Selection
  ///------------------------------------------------------------

  void clearSelection() {
    selectedDay.value = null;
  }

  ///------------------------------------------------------------
  /// Reset Calendar
  ///------------------------------------------------------------

  void resetCalendar() {
    selectedDay.value = null;

    monthDays.clear();

    generateCalendar();
  }

  ///------------------------------------------------------------
  /// Save Draft
  ///------------------------------------------------------------

  Future<String?> _saveDraftCore() async {
    if (!canEditCurrentPlan) {
      Get.snackbar(
        "Read Only",
        "This Tour Plan cannot be edited.",
      );
      return null;
    }

    // Show the detailed missing-day dialog first.
    if (!validateAllDaysAssigned()) {
      return null;
    }

    if (!validateTourPlan()) {
      return null;
    }

    if (isSavingDraft.value) {
      return null;
    }

    isSavingDraft.value = true;

    try {
      final body = buildDraftBody();

      debugPrint(
        '[TourPlanService] Saving ${monthTitle} with ' 
        '${(body['days'] as List).length} days',
      );

      final id = await service.saveDraft(body);

      if (id == null || id.isEmpty) {
        Get.snackbar(
          "Error",
          "Unable to save draft.",
          backgroundColor: TColors.error.withOpacity(.15),
        );
        return null;
      }

      draftId.value = id;

      // Keep local state coherent even if the details refresh is delayed.
      if (tourPlan.value == null) {
        _syncPlanState(
          TourPlanModel(
            id: id,
            userId: "",
            month: selectedMonth.value.month,
            year: selectedMonth.value.year,
            status: "Draft",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            days: const [],
          ),
        );
      }

      await refreshTourPlan();
      hasUnsavedChanges.value = false;
      return id;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: TColors.error.withOpacity(.15),
      );
      return null;
    } finally {
      isSavingDraft.value = false;
    }
  }

  Future<void> saveDraft() async {
    final id = await _saveDraftCore();
    if (id == null) return;

    Get.dialog(
      const DraftSavedDialog(),
      barrierDismissible: false,
    );
  }

  Future<bool> saveCurrentPlanDraft() async {
    final id = await _saveDraftCore();
    if (id == null) return false;

    Get.snackbar(
      "Success",
      "Draft saved successfully.",
    );
    return true;
  }

  /// =======================================================
  /// New Flow : Save + Submit
  /// =======================================================
  Future<void> submitCurrentPlan() async {

    if (!canEditCurrentPlan) {
      Get.snackbar(
        "Read Only",
        "This Tour Plan cannot be edited.",
      );
      return;
    }

    final saved = await saveCurrentPlanDraft();

    if (!saved) return;

    final submitted = await submitPlan();
    if (submitted) {
      Get.back(result: true);
    }
  }

  ///------------------------------------------------------------
  /// Submit Plan
  ///------------------------------------------------------------

  Future<bool> submitPlan() async {



    if (draftId.value.isEmpty) {
      Get.snackbar(
        "Draft Missing",
        "Please save draft before submitting.",
        backgroundColor: TColors.warning.withOpacity(.15),
      );
      return false;
    }

    isSubmitting.value = true;

    try {

      final success = await service.submitDraft(draftId.value);

      if (!success) {
        Get.snackbar(
          "Failed",
          "Unable to submit plan.",
        );
        return false;
      }

      if (tourPlan.value != null) {
        _syncPlanState(
          tourPlan.value!.copyWith(
            status: "Submitted",
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        currentStatus.value = "Submitted";
        isReadOnly.value = true;
      }

      Get.snackbar(
        "Success",
        "Tour Plan submitted successfully.",
        backgroundColor: TColors.success.withOpacity(.15),
      );

      return true;

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

      return false;

    } finally {

      isSubmitting.value = false;
    }
  }

  ///------------------------------------------------------------
  /// Refresh Current Tour Plan
  ///------------------------------------------------------------

  Future<void> refreshTourPlan() async {
    if (draftId.value.isEmpty) {
      return;
    }

    final result =
    await service.getTourPlanDetails(
      draftId.value,
    );

    if (result == null) {
      return;
    }

    _syncPlanState(result);
    selectedDay.value = null;
    generateCalendar();
    populateExistingDays();
    hasUnsavedChanges.value = false;
  }

  ///------------------------------------------------------------
  /// Reload Calendar
  ///------------------------------------------------------------

  Future<void> reloadCalendar() async {
    generateCalendar();

    if (tourPlan.value != null) {
      populateExistingDays();
    }
  }

  ///------------------------------------------------------------
  /// Reset Controller
  ///------------------------------------------------------------

  void resetController() {
    draftId.value = "";

    selectedDay.value = null;

    monthDays.clear();

    beats.clear();

    availableUsers.clear();

    collaborationStatus.clear();

    dayTypes.clear();

    _syncPlanState(null);
    hasUnsavedChanges.value = false;
    _availableUsersDate = null;

    selectedMonth.value =
        _defaultPlanningMonth();

    generateCalendar();
  }

  @override
  void onClose() {

    debugPrint("TourPlanController disposed");


    super.onClose();
  }
}