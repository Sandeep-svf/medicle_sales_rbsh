import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controller/tour_plan_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class DraftSavedDialog extends StatelessWidget {
  const DraftSavedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TourPlanController>();

    final summaryItems = [
      _SummaryItem(
        title: TTexts.uiTextFieldWork,
        count: controller.fieldCount,
        icon: Icons.location_on_rounded,
        color: TColors.materialBlue,
      ),
      _SummaryItem(
        title: TTexts.uiTextJointWork,
        count: controller.jointWorkCount,
        icon: Icons.people_alt_rounded,
        color: TColors.materialDeepPurple,
      ),
      _SummaryItem(
        title: TTexts.uiTextMeeting,
        count: controller.meetingCount,
        icon: Icons.groups_rounded,
        color: TColors.materialOrange,
      ),
      _SummaryItem(
        title: TTexts.uiTextOffice,
        count: controller.officeCount,
        icon: Icons.business_center_rounded,
        color: TColors.materialTeal,
      ),
      _SummaryItem(
        title: TTexts.uiTextTransit,
        count: controller.transitCount,
        icon: Icons.route_rounded,
        color: TColors.materialIndigo,
      ),
      _SummaryItem(
        title: TTexts.leave,
        count: controller.leaveCount,
        icon: Icons.beach_access_rounded,
        color: TColors.materialRedAccent,
      ),
      _SummaryItem(
        title: TTexts.holiday,
        count: controller.holidayCount,
        icon: Icons.celebration_rounded,
        color: TColors.materialGreen,
      ),
      _SummaryItem(
        title: TTexts.uiTextWeeklyOff,
        count: controller.weeklyOffCount,
        icon: Icons.weekend_rounded,
        color: TColors.materialBrown,
      ),
    ];

    final visibleItems = summaryItems.where((e) => e.count > 0).toList();

    final totalDays = visibleItems.fold<int>(
      0,
      (sum, e) => sum + e.count,
    );

    return PopScope(
      canPop: false,
      child: Dialog(
        elevation: TSizes.v0,
        backgroundColor: TColors.transparent,
        child: Container(
          width: TSizes.v720,
          constraints: const BoxConstraints(
            maxWidth: TSizes.v720,
          ),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //-------------------------------------------------
              // Header
              //-------------------------------------------------

              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: TSizes.v70,
                      height: TSizes.v70,
                      decoration: BoxDecoration(
                        color: TColors.white.withOpacity(.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: TColors.white,
                        size: TSizes.v42,
                      ),
                    ),
                    const SizedBox(width: TSizes.v18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TTexts.uiTextDraftSavedSuccessfully,
                            style: TextStyle(
                              fontSize: TSizes.v22,
                              fontWeight: FontWeight.bold,
                              color: TColors.white,
                            ),
                          ),
                          SizedBox(height: TSizes.v6),
                          Text(
                            TTexts.uiTextYourTourPlanHasBeenSavedSuccessfully +
                                "Review the summary below before submission.",
                            style: TextStyle(
                              color: TColors.white70,
                              height: TSizes.v1_5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //-------------------------------------------------
              // Body
              //-------------------------------------------------

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: TColors.primary,
                          ),
                          const SizedBox(width: TSizes.v12),
                          Expanded(
                            child: Text(
                              TTexts
                                  .uiTextReviewTheSummaryBelowThenSubmitThisTour,
                              style: TextStyle(
                                color: TColors.materialGrey700,
                                height: TSizes.v1_5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TSizes.v24),
                    Row(
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          color: TColors.primary,
                        ),
                        const SizedBox(width: TSizes.v8),
                        const Text(
                          TTexts.uiTextPlanningSummary,
                          style: TextStyle(
                            fontSize: TSizes.v18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "$totalDays Days",
                          style: const TextStyle(
                            color: TColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.v18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibleItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: TSizes.v16,
                        mainAxisSpacing: TSizes.v16,
                        childAspectRatio: 2.9,
                      ),
                      itemBuilder: (_, index) {
                        final item = visibleItems[index];

                        return _SummaryCard(item: item);
                      },
                    ),
                    const SizedBox(height: TSizes.v20),
                    const Divider(height: TSizes.v1),
                    const SizedBox(height: TSizes.v20),
                    Obx(() {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final success = await controller.submitPlan(
                                    showSuccessMessage: false,
                                  );

                                  if (success) {
                                    Get.back();

                                    Get.back(result: true);

                                    Get.snackbar(
                                      "Success",
                                      TTexts
                                          .uiTextTourPlanSubmittedSuccessfully,
                                      backgroundColor: TColors.success
                                          .withValues(alpha: .15),
                                    );
                                  }
                                },
                          icon: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: TSizes.v18,
                                  height: TSizes.v18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: TSizes.v2,
                                    color: TColors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(
                            controller.isSubmitting.value
                                ? "Submitting..."
                                : "Submit Tour Plan",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///--------------------------------------------------------------
/// Summary Model
///--------------------------------------------------------------

class _SummaryItem {
  final String title;

  final int count;

  final IconData icon;

  final Color color;

  const _SummaryItem({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });
}

///--------------------------------------------------------------
/// Summary Card
///--------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final _SummaryItem item;

  const _SummaryCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: item.color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.color.withOpacity(.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: TSizes.v44,
            height: TSizes.v44,
            decoration: BoxDecoration(
              color: item.color.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.color,
            ),
          ),
          const SizedBox(width: TSizes.v14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: TSizes.v14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: TSizes.v3),
                Text(
                  item.count == 1 ? "1 Day" : "${item.count} Days",
                  style: TextStyle(
                    color: TColors.materialGrey600,
                    fontSize: TSizes.v12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${item.count}",
            style: TextStyle(
              color: item.color,
              fontSize: TSizes.v24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
