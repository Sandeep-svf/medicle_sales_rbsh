import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../DayType.dart';
import '../controller/tour_plan_controller.dart';
import '../wigets/DayDetailsPanel.dart';
import '../wigets/custom_calander_grid.dart';
import '../wigets/day_editor_pannel.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

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
    _initializeController();
  }

  Future<void> _initializeController() async {
    final planId = widget.planId;

    await controller.initialize(createNew: planId == null);
    if (!mounted || planId == null) return;

    await controller.loadTourPlan(planId);
  }

  @override
  void dispose() {
    if (Get.isRegistered<TourPlanController>()) {
      final registered = Get.find<TourPlanController>();
      if (identical(registered, controller)) {
        Get.delete<TourPlanController>();
      }
    }
    super.dispose();
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
                child: Obx(
                  () => _buildHeader(controller),
                ),
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
              color: TColors.white,
            ),
          ),
          const SizedBox(width: TSizes.v10),
          const Icon(
            Icons.event_note,
            color: TColors.white,
            size: TSizes.v28,
          ),
          const SizedBox(width: TSizes.v12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  TTexts.uiTextTourPlan,
                  style: TextStyle(
                      fontSize: TSizes.v22,
                      fontWeight: FontWeight.bold,
                      color: TColors.white),
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
            onPressed: controller.isLoading.value
                ? null
                : () => controller.changePlanningMonth(context),
            icon: const Icon(
              Icons.calendar_month,
              color: TColors.white,
            ),
            label: Text(
              controller.monthTitle,
              style: TextStyle(color: TColors.white),
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
        elevation: TSizes.v0,
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
          radius: TSizes.v24,
          backgroundColor: TColors.primary_shade50,
          child: Icon(
            icon,
            color: TColors.primary,
          ),
        ),
        const SizedBox(width: TSizes.v12),
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
              const SizedBox(height: TSizes.v4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: TSizes.v17,
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
        // --------------------------------------------------------
        // CALENDAR
        // --------------------------------------------------------

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
              onDaySelected: (day) {
                if (controller.isViewMode) {
                  // READ ONLY
                  controller.selectedDay.value = day;
                } else {
                  // EDIT MODE
                  controller.selectEditableDay(day);
                }
              },
            ),
          ),
        ),

        const SizedBox(
          width: TSizes.lg,
        ),

        // --------------------------------------------------------
        // RIGHT PANEL
        // --------------------------------------------------------

        SizedBox(
          width: TSizes.v420,
          child: Container(
            margin: const EdgeInsets.only(
              right: TSizes.lg,
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
            child: controller.selectedDay.value == null
                ? const Center(
                    child: Text(
                      TTexts.uiTextSelectAnyWorkingDay,
                    ),
                  )
                : controller.isViewMode
                    ? DayDetailsPanel(
                        key: ValueKey(
                          controller.selectedDay.value!.date,
                        ),
                        day: controller.selectedDay.value!,
                        onClose: () {
                          controller.selectedDay.value = null;
                        },
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
          // ------------------------------------------------------
          // READ ONLY
          // ------------------------------------------------------

          if (controller.isViewMode) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: TColors.transparent,
              builder: (_) {
                return Container(
                  height: MediaQuery.of(context).size.height * .78,
                  decoration: const BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: DayDetailsPanel(
                    day: day,
                    onClose: () {
                      Get.back();
                    },
                  ),
                );
              },
            );

            return;
          }

          // ------------------------------------------------------
          // EDIT MODE
          // ------------------------------------------------------

          controller.selectEditableDay(day);

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: TColors.transparent,
            builder: (_) {
              return Container(
                height: MediaQuery.of(context).size.height * .72,
                decoration: const BoxDecoration(
                  color: TColors.white,
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
      height: TSizes.v88,
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.lg,
        vertical: TSizes.md,
      ),
      decoration: const BoxDecoration(
        color: TColors.white,
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
                  children: [
                    const Icon(
                      Icons.lock,
                      color: TColors.success,
                    ),
                    const SizedBox(width: TSizes.v10),
                    Expanded(
                      child: Text(
                        controller.isApprovedTourPlan
                            ? "This Tour Plan is approved and is read-only."
                            : "This Tour Plan is submitted and is read-only.",
                        style: const TextStyle(
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
              onPressed:
                  controller.isSavingDraft.value ? null : controller.saveDraft,
              icon: controller.isSavingDraft.value
                  ? const SizedBox(
                      width: TSizes.v18,
                      height: TSizes.v18,
                      child: CircularProgressIndicator(
                        strokeWidth: TSizes.v2,
                      ),
                    )
                  : const Icon(
                      Icons.save_outlined,
                    ),
              label: const Text(
                TTexts.uiTextSaveDraft,
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
                backgroundColor: TColors.materialOrange,
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
                        color: TColors.white,
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
