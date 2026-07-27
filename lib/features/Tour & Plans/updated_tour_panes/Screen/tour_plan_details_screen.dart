import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

import '../DayType.dart';
import '../controller/tour_plan_controller.dart';
import '../model/pre_submit_validation_modal.dart';
import '../wigets/custom_calander_grid.dart';
import '../wigets/day_editor_pannel.dart';

class TourPlanDetailsScreen extends StatefulWidget {
  const TourPlanDetailsScreen({
    super.key,
    this.planId,
  });

  final String? planId;

  @override
  State<TourPlanDetailsScreen> createState() => _TourPlanDetailsScreenState();
}

class _TourPlanDetailsScreenState extends State<TourPlanDetailsScreen> {
  late final TourPlanController controller;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: TColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    controller = Get.put(TourPlanController());

    if (widget.planId != null) {
      // Existing Tour Plan
      controller.initialize(createNew: false).then((_) {
        controller.loadTourPlan(widget.planId!);
      });
    } else {
      // New Tour Plan
      controller.initialize(createNew: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: TColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // iOS
      ),
      child: Scaffold(
        backgroundColor: TColors.light,
        body: Column(
          children: [
            Container(
              color: TColors.primary,
              child: SafeArea(
                bottom: false,
                child: _buildHeader(controller),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape = constraints.maxWidth >= 950;

                    return Column(
                      children: [
                        Obx(() => _buildSummary(controller)),
                        Expanded(
                          child: isLandscape
                              ? _buildLandscape(controller)
                              : _buildPortrait(context, controller),
                        ),
                        _buildBottomActionBar(controller),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  //------------------------------------------------------------
  Widget _buildHeader(
    TourPlanController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.lg,
        vertical: TSizes.md,
      ),
      color: TColors.primary,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.event_note,
            color: TColors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tour Plan",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
                Text(
                  controller.monthTitle,
                  style: const TextStyle(
                    color: TColors.white,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: controller.isNewTourPlan
                ? () => controller.changePlanningMonth(context)
                : null,
            icon: const Icon(
              Icons.calendar_month,
              color: Colors.white,
            ),
            label: Text(
              controller.monthTitle,
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }

  //------------------------------------------------------------
  Widget _buildSummary(
    TourPlanController controller,
  ) {
    return Container(
      margin: const EdgeInsets.all(
        TSizes.lg,
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            TSizes.cardRadiusLg,
          ),
          side: const BorderSide(
            color: TColors.borderSecondary,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            TSizes.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: _summaryTile(
                  "Month",
                  controller.monthTitle,
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _summaryTile(
                  "Status",
                  controller.tourPlan.value?.status ?? "Draft",
                  Icons.edit_note,
                ),
              ),
              Expanded(
                child: _summaryTile(
                  "Planned",
                  "${controller.monthDays.where((e) => e.type != DayType.unassigned && e.type != DayType.holiday).length}/${controller.monthDays.length}",
                  Icons.task_alt,
                ),
              ),
              Expanded(
                child: _summaryTile(
                  "Working Days",
                  "${controller.monthDays.where((e) => e.type == DayType.field || e.type == DayType.jointWork || e.type == DayType.meeting || e.type == DayType.office || e.type == DayType.transit).length}",
                  Icons.work,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile(
      String title,
      String value,
      IconData icon,
      ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: TColors.primary_shade50,
          child: Icon(
            icon,
            color: TColors.primary,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //------------------------------------------------------------
  Widget _buildLandscape(
    TourPlanController controller,
  ) {
    return Row(
      children: [
        /// Calendar

        Expanded(
          flex: 7,
          child: Container(
            margin: const EdgeInsets.only(
              left: TSizes.lg,
              bottom: TSizes.lg,
            ),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(
                TSizes.cardRadiusLg,
              ),
              border: Border.all(
                color: TColors.borderSecondary,
              ),
            ),
            child: CustomCalendarGrid(
              days: controller.monthDays,
              selectedDay: controller.selectedDay.value,
              onDaySelected: controller.selectEditableDay,
            ),
          ),
        ),

        const SizedBox(
          width: TSizes.lg,
        ),

        /// Editor

        SizedBox(
          width: 420,
          child: Container(
            margin: const EdgeInsets.only(
              right: TSizes.lg,
              bottom: TSizes.lg,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                TSizes.cardRadiusLg,
              ),
              border: Border.all(
                color: TColors.borderSecondary,
              ),
            ),
            child: controller.selectedDay.value == null
                ? const Center(
                    child: Text(
                      "Select any working day",
                    ),
                  )
                : DayEditorPanel(
                    key: ValueKey(
                      controller.selectedDay.value!.date,
                    ),
                    day: controller.selectedDay.value!,
                    onClose: () {
                      controller.selectedDay.value = null;
                    },
                    onDayUpdated: controller.updateDay,
                  ),
          ),
        ),
      ],
    );
  }

  //------------------------------------------------------------
  Widget _buildPortrait(
    BuildContext context,
    TourPlanController controller,
  ) {
    return Obx(
          () => CustomCalendarGrid(
        days: controller.monthDays,
        selectedDay: controller.selectedDay.value,
        onDaySelected: (day) {
          controller.selectEditableDay(day);

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) {
              return Container(
                height: MediaQuery.of(context).size.height * .72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: DayEditorPanel(
                  day: day,
                  onClose: () {
                    Get.back();
                  },
                  onDayUpdated: controller.updateDay,
                ),
              );
            },
          );
        },
      ),
    );
  }

  //------------------------------------------------------------
  Widget _buildBottomActionBar(
    TourPlanController controller,
  ) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.lg,
        vertical: TSizes.md,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: TColors.borderSecondary,
          ),
        ),
      ),
      child: Row(
        children: [
          if (controller.isViewMode)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TColors.success.withOpacity(.08),
                  borderRadius: BorderRadius.circular(
                    TSizes.cardRadiusMd,
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.lock,
                      color: TColors.success,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Save your changes as a draft before submitting the tour plan.",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (controller.canEditCurrentPlan) ...[
            OutlinedButton.icon(
              onPressed: controller.isSavingDraft.value
            ? null
                : controller.saveDraft,
              icon: controller.isSavingDraft.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.save_outlined,
                    ),
              label: const Text(
                "Save Draft",
              ),
            ),
            const SizedBox(width: TSizes.md),
            /*ElevatedButton.icon(
              onPressed: () {
                /// Validation Dialog
                showDialog(
                  context: Get.context!,
                  builder: (_) => const PreSubmitValidationModal(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              icon: const Icon(
                Icons.fact_check,
              ),
              label: const Text(
                "Validate",
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed:
                  controller.isSubmitting.value ? null : controller.submitPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
              ),
              icon: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      controller.currentStatus.value == "Returned"
                          ? Icons.refresh
                          : Icons.send,
                    ),
              label: Text(
                controller.currentStatus.value == "Returned"
                    ? "Submit Again"
                    : "Submit",
              ),
            ),*/
          ],
        ],
      ),
    );
  }
}
