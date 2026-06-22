import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/colors.dart';
import '../controller/tour_plan_controller.dart';
import '../wigets/custom_calander_grid.dart';
import '../wigets/day_editor_pannel.dart';


class MtpScreen extends StatelessWidget {
  const MtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TourPlanController());

    return Scaffold(
      backgroundColor: TColors.light,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: TColors.primary));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isLandscape = constraints.maxWidth > 1000;

              return Column(
                children: [
                  _buildTopAppRibbon(controller),
                  Expanded(
                    child: isLandscape
                        ? _buildHorizontalLayout(controller)
                        : _buildVerticalLayout(controller, context),
                  ),
                  _buildActionControls(controller),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildTopAppRibbon(TourPlanController controller) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: TColors.white, border: Border(bottom: BorderSide(color: TColors.borderSecondary))),
      child: Row(
        children: [
          const Icon(Icons.calendar_view_month, color: TColors.primary, size: 28),
          const SizedBox(width: 14),
          Text(
            controller.monthTitle.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TColors.textPrimary, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(TourPlanController controller) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: CustomCalendarGrid(
            days: controller.monthDays,
            selectedDay: controller.selectedDay.value,
            onDaySelected: controller.selectDay,
          ),
        ),
        Container(width: 1, color: TColors.borderSecondary),
        SizedBox(
          width: 400,
          child: DayEditorPanel(
            key: ValueKey(controller.selectedDay.value?.date),
            day: controller.selectedDay.value ?? controller.monthDays.first,
            onClose: () => controller.selectedDay.value = null,
            onDayUpdated: controller.updateDay,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(TourPlanController controller, BuildContext context) {
    return CustomCalendarGrid(
      days: controller.monthDays,
      selectedDay: controller.selectedDay.value,
      onDaySelected: (day) {
        controller.selectDay(day);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: const BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DayEditorPanel(
              day: day,
              onClose: () => Get.back(),
              onDayUpdated: controller.updateDay,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionControls(TourPlanController controller) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(color: TColors.white, border: Border(top: BorderSide(color: TColors.borderSecondary))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            onPressed: controller.isSavingDraft.value ? null : () => controller.saveDraft(),
            icon: controller.isSavingDraft.value ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.drafts),
            label: const Text("SAVE PROGRESS DRAFT"),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: controller.isSubmitting.value ? null : () => controller.submitPlan(),
            icon: controller.isSubmitting.value ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.cloud_upload),
            label: const Text("SUBMIT FINAL TOUR PLAN"),
          ),
        ],
      ),
    );
  }
}