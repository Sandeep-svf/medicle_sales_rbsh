import 'package:get/get.dart';
import '../../../../utils/constants/colors.dart';
import '../../../Holiday/controller/HolidayController.dart';
import '../../../Holiday/models/Holiday.dart';
import '../DayType.dart';
import '../model/TourDay.dart';
import '../model/beat_model.dart';
import '../model/available_user_model.dart';
import '../service/TourPlanService.dart';
// SYNC FIXED: Importing your real Holiday models and controller configurations


class TourPlanController extends GetxController {
  final TourPlanService service = TourPlanService();

  final RxBool isLoading = false.obs;
  final RxBool isSavingDraft = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<TourDay> monthDays = <TourDay>[].obs;
  final RxList<BeatModel> beats = <BeatModel>[].obs;
  final RxList<AvailableUserModel> availableUsers = <AvailableUserModel>[].obs;
  final Rx<TourDay?> selectedDay = Rx<TourDay?>(null);

  String? draftId;

  DateTime get planningMonth {
    final now = DateTime.now();
    if (now.month == 12) {
      return DateTime(now.year + 1, 1, 1);
    }
    return DateTime(now.year, now.month + 1, 1);
  }

  String get monthTitle {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return "${months[planningMonth.month]} ${planningMonth.year}";
  }

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  Future<void> initializeData() async {
    isLoading.value = true;
    try {
      await loadBeats();
      generateCalendar();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBeats() async {
    final fetchedBeats = await service.getBeats();
    beats.assignAll(fetchedBeats);
  }

  Future<void> loadAvailableUsers(DateTime date) async {
    final fetchedUsers = await service.getAvailableUsers(date);
    availableUsers.assignAll(fetchedUsers.where((user) => user.available).toList());
  }

  /// Generates the planning calendar matrix matching Sundays and Holiday Controller indices
  /// Generates the planning calendar matrix matching Sundays and Holiday Controller indices
  void generateCalendar() {
    // FIX: Checks if registered; if not, instantiates it dynamically on the fly
    final holidayController = Get.isRegistered<HolidayController>()
        ? Get.find<HolidayController>()
        : Get.put(HolidayController());

    monthDays.clear();

    final totalDays = DateTime(planningMonth.year, planningMonth.month + 1, 0).day;

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(planningMonth.year, planningMonth.month, day);

      // Sundays are absolute read-only blocks
      if (date.weekday == DateTime.sunday) {
        monthDays.add(TourDay(
          date: date,
          type: DayType.holiday,
          holidayName: "Weekly Off",
          notes: "Sunday Off",
        ));
        continue;
      }

      // Cross-verifying target dates against fetched holiday objects
      final Holiday? activeHoliday = holidayController.holidays.firstWhereOrNull(
            (h) => h.date.year == date.year && h.date.month == date.month && h.date.day == date.day,
      );

      if (activeHoliday != null) {
        monthDays.add(TourDay(
          date: date,
          type: DayType.holiday,
          holidayName: activeHoliday.title,
          notes: activeHoliday.description.isNotEmpty ? activeHoliday.description : activeHoliday.title,
        ));
        continue;
      }

      // Default editable state
      monthDays.add(TourDay(
        date: date,
        type: DayType.unassigned,
      ));
    }
  }

  void selectDay(TourDay day) {
    selectedDay.value = day;
    if (day.type == DayType.jointWork) {
      loadAvailableUsers(day.date);
    }
  }

  void updateDay(TourDay updatedDay) {
    final index = monthDays.indexWhere(
          (e) => e.date.year == updatedDay.date.year && e.date.month == updatedDay.date.month && e.date.day == updatedDay.date.day,
    );
    if (index == -1) return;
    monthDays[index] = updatedDay;
    monthDays.refresh();
    selectedDay.value = updatedDay;
  }

  String _mapEnumToApiType(DayType type) {
    switch (type) {
      case DayType.field: return "Field";
      case DayType.meeting: return "Meeting";
      case DayType.jointWork: return "Joint Work";
      case DayType.leave: return "Leave";
      case DayType.holiday: return "Holiday";
      case DayType.unassigned: return "Unassigned";
    }
  }

  Future<void> saveDraft() async {
    isSavingDraft.value = true;
    try {
      final body = {
        "month": planningMonth.month,
        "year": planningMonth.year,
        "days": monthDays.map((day) => {
          "date": day.date.toIso8601String().split("T").first,
          "day_type": _mapEnumToApiType(day.type),
          "beat_id_1": day.beatId,
          "notes": day.notes ?? "",
        }).toList(),
      };

      final id = await service.saveDraft(body);
      if (id != null) {
        draftId = id;
        Get.snackbar("Success", "Draft saved successfully", backgroundColor: TColors.success.withOpacity(0.2));
      }
    } finally {
      isSavingDraft.value = false;
    }
  }

  Future<void> submitPlan() async {
    if (draftId == null) {
      Get.snackbar("Error", "Please save draft before submitting.", backgroundColor: TColors.error.withOpacity(0.2));
      return;
    }
    isSubmitting.value = true;
    try {
      final success = await service.submitDraft(draftId!);
      if (success) {
        Get.snackbar("Success", "Plan submitted successfully for approval", backgroundColor: TColors.success.withOpacity(0.2));
      }
    } catch (e) {
      Get.snackbar("Error", "Submission failed.", backgroundColor: TColors.error.withOpacity(0.2));
    } finally {
      isSubmitting.value = false;
    }
  }
}