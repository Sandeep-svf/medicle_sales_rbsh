import 'package:get/get.dart';

import '../../../leaves/controller/LeaveController.dart';

import '../DayType.dart';

import '../model/TourDay.dart';
import '../model/available_user_model.dart';
import '../model/beat_model.dart';

import '../service/mtp_service.dart';

class TourPlanController extends GetxController {

  final MtpService service = MtpService();

  final RxBool isLoading = false.obs;
  final RxBool isSavingDraft = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<TourDay> monthDays =
      <TourDay>[].obs;

  final RxList<BeatModel> beats =
      <BeatModel>[].obs;

  final RxList<AvailableUserModel>
  availableUsers =
      <AvailableUserModel>[].obs;

  final Rx<TourDay?> selectedDay =
  Rx<TourDay?>(null);

  String? draftId;

  DateTime get planningMonth {

    final now = DateTime.now();

    if (now.month == 12) {
      return DateTime(
        now.year + 1,
        1,
        1,
      );
    }

    return DateTime(
      now.year,
      now.month + 1,
      1,
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
      "${months[planningMonth.month]} ${planningMonth.year}";
  }

  @override
  void onInit() {
    super.onInit();

    initialize();
  }

  Future<void> initialize() async {

    isLoading.value = true;

    try {

      await loadBeats();

      generateCalendar();

    } finally {

      isLoading.value = false;
    }
  }

  Future<void> loadBeats() async {

    beats.assignAll(
      await service.getBeats(),
    );
  }

  Future<void> loadAvailableUsers(
      DateTime date,
      ) async {

    availableUsers.assignAll(
      await service.getAvailableUsers(
        date,
      ),
    );
  }

  void generateCalendar() {

    final leaveController =
    Get.find<LeaveController>();

    monthDays.clear();

    final totalDays =
        DateTime(
          planningMonth.year,
          planningMonth.month + 1,
          0,
        ).day;

    for (
    int day = 1;
    day <= totalDays;
    day++
    ) {

      final date = DateTime(
        planningMonth.year,
        planningMonth.month,
        day,
      );

      // Sunday

      if (
      date.weekday ==
          DateTime.sunday
      ) {

        monthDays.add(
          TourDay(
            date: date,
            type: DayType.holiday,
            holidayName:
            "Weekly Off",
            notes:
            "Sunday Off",
          ),
        );

        continue;
      }

      // Holiday

      final holiday =
      leaveController.holidays
          .firstWhereOrNull(
            (e) =>
        e.date.year ==
            date.year &&
            e.date.month ==
                date.month &&
            e.date.day ==
                date.day,
      );

      if (holiday != null) {

        monthDays.add(
          TourDay(
            date: date,
            type: DayType.holiday,
            holidayName:
            holiday.title,
            notes:
            holiday.title,
          ),
        );

        continue;
      }

      // Working Day

      monthDays.add(
        TourDay(
          date: date,
          type:
          DayType.unassigned,
        ),
      );
    }
  }

  void selectDay(
      TourDay day,
      ) {

    selectedDay.value = day;

    if (
    day.type ==
        DayType.jointWork
    ) {

      loadAvailableUsers(
        day.date,
      );
    }
  }

  void updateDay(
      TourDay updatedDay,
      ) {

    final index =
    monthDays.indexWhere(
          (e) =>
      e.date.year ==
          updatedDay.date.year &&
          e.date.month ==
              updatedDay.date.month &&
          e.date.day ==
              updatedDay.date.day,
    );

    if (index == -1) {
      return;
    }

    monthDays[index] =
        updatedDay;

    monthDays.refresh();

    selectedDay.value =
        updatedDay;
  }

  String mapDayType(
      DayType type,
      ) {

    switch (type) {

      case DayType.field:
        return "Field";

      case DayType.meeting:
        return "Meeting";

      case DayType.jointWork:
        return "Joint Work";

      case DayType.leave:
        return "Leave";

      case DayType.holiday:
        return "Holiday";

      case DayType.unassigned:
        return "Unassigned";
    }
  }

  Map<String, dynamic>
  buildDraftBody() {

    return {

      "month":
      planningMonth.month,

      "year":
      planningMonth.year,

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
            mapDayType(
              day.type,
            ),

            "beat_id_1":
            day.beatId,

            "notes":
            day.notes ?? "",
          };
        },
      ).toList(),
    };
  }

  Future<void>
  saveDraft() async {

    isSavingDraft.value =
    true;

    try {

      final body =
      buildDraftBody();

      draftId =
      await service
          .saveDraft(
        body,
      );

      Get.snackbar(
        "Success",
        "Draft Saved",
      );

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isSavingDraft.value =
      false;
    }
  }

  Future<void>
  submitPlan() async {

    if (draftId == null) {

      Get.snackbar(
        "Draft Missing",
        "Please save draft first",
      );

      return;
    }

    isSubmitting.value =
    true;

    try {

      await service.submitPlan(
        draftId!,
      );

      Get.snackbar(
        "Success",
        "Plan Submitted",
      );

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isSubmitting.value =
      false;
    }
  }
}