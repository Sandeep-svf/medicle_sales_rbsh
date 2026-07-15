import 'package:flutter/cupertino.dart';
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
import '../wigets/draft_saved_dialog.dart';



class TourPlanController extends GetxController {

  final TourPlanService service =
  TourPlanService();

  final RxString currentStatus = "Draft".obs;

  bool get readOnly =>
      currentStatus.value == "Submitted" ||
          currentStatus.value == "Approved";

  bool get canSubmit =>
      currentStatus.value == "Draft" ||
          currentStatus.value == "Returned";



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
      tourPlan.value?.status ==
          "Submitted";

  bool get isApproved =>
      tourPlan.value?.status ==
          "Approved";

  bool get isReturned =>
      tourPlan.value?.status ==
          "Returned";

  bool get canEdit {
    if (tourPlan.value == null) {
      return true;
    }

    return

      isDraft ||

          isReturned;
  }



  /// =======================================================
  /// New Flow Helpers (Safe - Doesn't affect existing code)
  /// =======================================================

  /// Creating a brand new Tour Plan
  bool get isNewTourPlan =>
      tourPlan.value == null;

  /// Existing Returned plan
  bool get isReturnedTourPlan =>
      currentStatus.value == "Returned";

  /// Existing Submitted plan
  bool get isSubmittedTourPlan =>
      currentStatus.value == "Submitted";

  /// Existing Approved plan
  bool get isApprovedTourPlan =>
      currentStatus.value == "Approved";

  /// Existing Draft from List
  bool get isDraftTourPlan =>
      currentStatus.value == "Draft";

  /// Only New + Returned are editable
  bool get canEditCurrentPlan =>
      isNewTourPlan || isReturnedTourPlan;

  /// Read only plans
  bool get isViewMode =>
      isSubmittedTourPlan ||
          isApprovedTourPlan ||
          isDraftTourPlan;






  ///--------------------------------------------------------------
  /// Change Planning Month
  ///--------------------------------------------------------------
  Future<void> changePlanningMonth(BuildContext context) async {
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
    final result =
    await service.getBeats();

    beats.assignAll(result);
  }

  Future<void> loadAvailableUsers(DateTime date,) async {
    final result =
    await service
        .getAvailableUsers(date);

    availableUsers.assignAll(
      result.where(
            (e) => e.available,
      ),
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

  Future<void> loadTourPlan(String tourPlanId) async {

    debugPrint("========== TourPlanController ==========");
    debugPrint("TourPlanController loadTourPlan()");
    debugPrint("TourPlanController Plan Id : $tourPlanId");
    debugPrint("========================================");

    isLoading.value = true;

    try {

      selectedDay.value = null;
      monthDays.clear();

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Calling Details API...");
      debugPrint("========================================");

      final response = await service.getTourPlanDetails(
        tourPlanId,
      );

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


      if (response == null) {

        debugPrint("========== TourPlanController ==========");
        debugPrint("TourPlanController API Response : NULL");
        debugPrint("========================================");

        return;
      }

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController API Success");
      debugPrint("TourPlanController TourPlan Id : ${response.id}");
      debugPrint("TourPlanController Status      : ${response.status}");
      debugPrint("TourPlanController Month       : ${response.month}");
      debugPrint("TourPlanController Year        : ${response.year}");
      debugPrint("TourPlanController Days Count  : ${response.days.length}");
      debugPrint("========================================");

      tourPlan.value = response;

      currentStatus.value = response.status;

      draftId.value = response.id;

      selectedMonth.value = DateTime(
        response.year,
        response.month,
      );

      isReadOnly.value =
          response.status == "Submitted" ||
              response.status == "Approved";

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Generating Calendar...");
      debugPrint("========================================");

      generateCalendar();

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Month Days Before Populate : ${monthDays.length}");
      debugPrint("========================================");

      populateExistingDays();

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

    } catch (e, stack) {

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController ERROR");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      debugPrint("========================================");

    } finally {

      isLoading.value = false;

      debugPrint("========== TourPlanController ==========");
      debugPrint("TourPlanController Loading Finished");
      debugPrint("========================================");
    }
  }



  Future<void> createNewTourPlan() async {
    tourPlan.value = null;

    draftId.value = "";

    isReadOnly.value = false;

    selectedDay.value = null;

    monthDays.clear();

    generateCalendar();
  }

  void changeMonth(DateTime month,) {
    if (!canEdit) {
      return;
    }

    selectedMonth.value = month;

    selectedDay.value = null;

    generateCalendar();
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
        type: mapApiDayType(apiDay.dayType),

        apiDayType: apiDay.dayType,

        beatId: apiDay.beatId1,

        beatName: apiDay.dayType == "Field"
            ? (apiDay.beat1?["name"] as String?)
            : null,

        jointWorkUserId: apiDay.jointWorkWithUserId,

        jointWorkUserName: apiDay.jointWorkWith?["name"],

        notes: apiDay.notes,

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

  void selectDay(TourDay day,) {
    if (isReadOnly.value) {
      return;
    }

    if (

    day.holidayName == "Weekly Off" ||

        day.type == DayType.holiday

    ) {
      return;
    }

    selectedDay.value = day;

    if (

    day.type == DayType.jointWork

    ) {
      loadAvailableUsers(
        day.date,
      );
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
    }
  }

  void updateDay(TourDay updatedDay,) {
    if (isReadOnly.value) {
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

    if (day.apiDayType == "Office") {
      if ((day.notes ?? "")
          .trim()
          .isEmpty) {
        return "Office remarks are required.";
      }
    }

    /// Transit

    if (day.apiDayType == "Transit") {
      if ((day.notes ?? "")
          .trim()
          .isEmpty) {
        return "Transit remarks are required.";
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
      monthDays.where((e) => e.apiDayType == "Field").length;

  int get jointWorkCount =>
      monthDays.where((e) => e.apiDayType == "Joint work").length;

  int get meetingCount =>
      monthDays.where((e) => e.apiDayType == "Meeting").length;

  int get officeCount =>
      monthDays.where((e) => e.apiDayType == "Office").length;

  int get transitCount =>
      monthDays.where((e) => e.apiDayType == "Transit").length;

  int get leaveCount =>
      monthDays.where((e) => e.apiDayType == "Leave").length;

  int get holidayCount =>
      monthDays.where(
            (e) =>
        e.apiDayType == "Holiday" &&
            !e.isWeeklyOff,
      ).length;

  int get weeklyOffCount =>
      monthDays.where((e) => e.isWeeklyOff).length;

  ///------------------------------------------------------------
  /// UI Enum -> API
  ///------------------------------------------------------------

  String mapDayType(TourDay day) {
    if (

    day.apiDayType != null &&

        day.apiDayType!.isNotEmpty

    ) {
      return day.apiDayType!;
    }

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
        return "Field";
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

            "joint_work_with_user_id":

            day.jointWorkUserId,

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

  Future<void> saveDraft() async {
    if (!validateTourPlan()) {
      return;
    }

    isSavingDraft.value = true;

    try {
      final body = buildDraftBody();

      final id = await service.saveDraft(body);

      if (id == null || id.isEmpty) {
        Get.snackbar(
          "Error",
          "Unable to save draft.",
          backgroundColor: TColors.error.withOpacity(.15),
        );

        return;
      }

      draftId.value = id;

      /// New Draft

      if (tourPlan.value == null) {
        tourPlan.value = TourPlanModel(
          id: id,
          userId: "",
          month: selectedMonth.value.month,
          year: selectedMonth.value.year,
          status: "Draft",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          days: const [],
        );
      }

      await refreshTourPlan();

      Get.dialog(
        const DraftSavedDialog(),
        barrierDismissible: false,
      );

      /// Refresh latest server data


    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: TColors.error.withOpacity(.15),
      );
    } finally {
      isSavingDraft.value = false;
    }
  }

  /// =======================================================
  /// New Flow : Save Draft (New + Returned)
  /// =======================================================
  Future<bool> saveCurrentPlanDraft() async {

    if (!canEditCurrentPlan) {
      Get.snackbar(
        "Read Only",
        "This Tour Plan cannot be edited.",
      );
      return false;
    }

    if (!validateTourPlan()) {
      return false;
    }

    isSavingDraft.value = true;

    try {

      final body = buildDraftBody();

      final id = await service.saveDraft(body);

      if (id == null || id.isEmpty) {

        Get.snackbar(
          "Error",
          "Unable to save draft.",
        );

        return false;
      }

      draftId.value = id;

      await refreshTourPlan();

      Get.snackbar(
        "Success",
        "Draft saved successfully.",
      );

      return true;

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

      return false;

    } finally {

      isSavingDraft.value = false;
    }
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

    await submitPlan();
  }

  ///------------------------------------------------------------
  /// Submit Plan
  ///------------------------------------------------------------

  Future<bool> submitPlan() async {

    if (!validateTourPlan()) {
      return false;
    }

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
        tourPlan.value = tourPlan.value!.copyWith(
          status: "Submitted",
          updatedAt: DateTime.now(),
        );
      }

      isReadOnly.value = true;

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

    tourPlan.value = result;

    populateExistingDays();
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

    tourPlan.value = null;

    isReadOnly.value = false;

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