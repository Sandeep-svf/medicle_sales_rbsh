import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'tour_plan_table.dart';
import '../controller/tour_plan_list_controller.dart';
import '../model/tour_plan_model.dart';
import '../wigets/status_chip.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class TourPlanListScreen extends StatelessWidget {
  const TourPlanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TourPlanListController());

    return Scaffold(
      backgroundColor: TColors.light,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "createTourPlan",
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        onPressed: controller.createTourPlan,
        icon: const Icon(Icons.add),
        label: const Text(TTexts.uiTextCreateTourPlan),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: TColors.primary,
              ),
            );
          }

          return Column(
            children: [
              _buildHeader(controller),
              Expanded(
                child: RefreshIndicator(
                  color: TColors.primary,
                  onRefresh: controller.refreshList,
                  notificationPredicate: (notification) =>
                      notification.metrics.axis == Axis.vertical,
                  child: controller.isEmpty
                      ? _buildEmptyState()
                      : controller.isTableView.value
                          ? TourPlanTable(
                              plans: controller.filteredPlans,
                              onDetails: controller.openDetails,
                              onSubmit: controller.submitDraftFromList,
                              submittingPlanId:
                                  controller.submittingPlanId.value,
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildPlanGrid(
                                  controller,
                                  showTwoColumns: constraints.maxWidth >= 720,
                                );
                              },
                            ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(TourPlanListController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        TSizes.lg,
        TSizes.lg,
        TSizes.lg,
        0,
      ),
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withValues(alpha: .18),
            blurRadius: TSizes.v18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = _buildHeaderTitle(controller);
          final toggle = _buildViewToggle(controller);

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: TSizes.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: toggle,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: TSizes.md),
              toggle,
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderTitle(TourPlanListController controller) {
    return Row(
      children: [
        Container(
          width: TSizes.v58,
          height: TSizes.v58,
          decoration: BoxDecoration(
            color: TColors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: TColors.white,
            size: TSizes.v32,
          ),
        ),
        const SizedBox(width: TSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                TTexts.tourPlans,
                style: TextStyle(
                  color: TColors.white,
                  fontSize: TSizes.v24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: TSizes.v5),
              Text(
                "${controller.totalPlans} plans • Plan and track monthly activity",
                style: const TextStyle(
                  color: TColors.white70,
                  height: TSizes.v1_3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle(TourPlanListController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TColors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewOption(
            icon: Icons.table_rows_rounded,
            label: TTexts.uiTextTable,
            isSelected: controller.isTableView.value,
            onTap: () => controller.changeView(showTable: true),
          ),
          _buildViewOption(
            icon: Icons.grid_view_rounded,
            label: TTexts.uiTextCards,
            isSelected: !controller.isTableView.value,
            onTap: () => controller.changeView(showTable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: isSelected ? TColors.white : TColors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: TSizes.v18,
              color: isSelected ? TColors.primary : TColors.white,
            ),
            const SizedBox(width: TSizes.v6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? TColors.primary : TColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanGrid(
    TourPlanListController controller, {
    required bool showTwoColumns,
  }) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        TSizes.lg,
        TSizes.lg,
        TSizes.lg,
        96,
      ),
      itemCount: controller.filteredPlans.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: showTwoColumns ? 2 : 1,
        crossAxisSpacing: TSizes.md,
        mainAxisSpacing: TSizes.md,
        mainAxisExtent: 310,
      ),
      itemBuilder: (context, index) {
        final plan = controller.filteredPlans[index];
        return _buildPlanCard(controller, plan);
      },
    );
  }

  Widget _buildPlanCard(
    TourPlanListController controller,
    TourPlanModel plan,
  ) {
    final remarks = plan.comments?.trim() ?? '';

    return Card(
      margin: EdgeInsets.zero,
      elevation: TSizes.v2,
      shadowColor: TColors.primary.withValues(alpha: .12),
      surfaceTintColor: TColors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        side: const BorderSide(color: TColors.borderSecondary),
      ),
      child: InkWell(
        onTap: () => controller.openDetails(plan),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: TSizes.v46,
                    height: TSizes.v46,
                    decoration: BoxDecoration(
                      color: TColors.primary_shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: TColors.primary,
                    ),
                  ),
                  const SizedBox(width: TSizes.v12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.monthName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: TColors.textPrimary,
                            fontSize: TSizes.v18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: TSizes.v3),
                        const Text(
                          TTexts.uiTextMonthlyTourPlan,
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontSize: TSizes.v12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TSizes.v8),
                  StatusChip(status: plan.status),
                ],
              ),
              const SizedBox(height: TSizes.v14),
              const Divider(height: TSizes.v1),
              const SizedBox(height: TSizes.v14),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_view_day_outlined,
                      label: TTexts.uiTextPlannedDays,
                      value: plan.days.length.toString(),
                    ),
                  ),
                  const SizedBox(width: TSizes.md),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.schedule_outlined,
                      label: TTexts.uiTextCreated,
                      value: _formatDate(plan.createdAt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.v12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: remarks.isEmpty
                      ? TColors.softGrey
                      : TColors.materialRed.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      remarks.isEmpty
                          ? Icons.notes_rounded
                          : Icons.info_outline_rounded,
                      size: TSizes.v17,
                      color: remarks.isEmpty
                          ? TColors.textSecondary
                          : TColors.materialRed,
                    ),
                    const SizedBox(width: TSizes.v8),
                    Expanded(
                      child: Text(
                        remarks.isEmpty ? "No remarks added" : remarks,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: remarks.isEmpty
                              ? TColors.textSecondary
                              : TColors.materialRed,
                          fontSize: TSizes.v13,
                          fontWeight: remarks.isEmpty
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.openDetails(plan),
                      icon: Icon(
                        plan.canEdit
                            ? Icons.edit_outlined
                            : Icons.visibility_outlined,
                        size: TSizes.v18,
                      ),
                      label: Text(
                        plan.canEdit ? "Edit Plan" : "View Details",
                      ),
                    ),
                  ),
                  if (plan.isDraft) ...[
                    const SizedBox(width: TSizes.v10),
                    Expanded(
                      child: Obx(() {
                        final isSubmitting =
                            controller.submittingPlanId.value == plan.id;

                        return ElevatedButton.icon(
                          onPressed:
                              controller.submittingPlanId.value.isNotEmpty
                                  ? null
                                  : () => controller.submitDraftFromList(plan),
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: TSizes.v16,
                                  height: TSizes.v16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: TSizes.v2,
                                    color: TColors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded,
                                  size: TSizes.v18),
                          label: Text(isSubmitting ? "Submitting" : "Submit"),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: TSizes.v18, color: TColors.primary),
        const SizedBox(width: TSizes.v8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: TSizes.v11,
                ),
              ),
              const SizedBox(height: TSizes.v2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TColors.textPrimary,
                  fontSize: TSizes.v13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: TSizes.v80,
                  color: TColors.textSecondary,
                ),
                SizedBox(height: TSizes.v16),
                Text(
                  TTexts.uiTextNoTourPlansFound,
                  style: TextStyle(
                    fontSize: TSizes.v18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: TSizes.v8),
                Text(TTexts.uiTextPullDownToRefreshOrCreateANew),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return "${date.day.toString().padLeft(2, '0')} "
        "${months[date.month]} ${date.year}";
  }
}
