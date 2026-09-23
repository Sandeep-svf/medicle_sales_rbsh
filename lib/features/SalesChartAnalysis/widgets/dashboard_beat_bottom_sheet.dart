import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/DashboardController.dart';
import '../model/dashboard_beat_model.dart';
import 'dashboard_beat_reason_dialog.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class DashboardBeatBottomSheet extends StatelessWidget {
  const DashboardBeatBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Container(
      height: MediaQuery.of(context).size.height * .85,
      decoration: const BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            //--------------------------------------------------
            // Drag Handle
            //--------------------------------------------------
            const SizedBox(height: TSizes.v10),
            Container(
              width: TSizes.v55,
              height: TSizes.v5,
              decoration: BoxDecoration(
                color: TColors.materialGrey300,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: TSizes.md),

            //--------------------------------------------------
            // Header
            //--------------------------------------------------
            const Text(
              TTexts.uiTextSwitchTodaySBeat,
              style: TextStyle(
                fontSize: TSizes.v22,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: TSizes.v6),
            const Text(
              TTexts.uiTextChooseAnotherBeatForTodaySFieldWork,
              style: TextStyle(
                color: TColors.textSecondary,
                fontSize: TSizes.v14,
              ),
            ),
            const SizedBox(height: TSizes.lg),

            //--------------------------------------------------
            // Search
            //--------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TSizes.md,
              ),
              child: TextField(
                controller: controller.dashboardBeatSearchController,
                onChanged: controller.filterDashboardBeats,
                decoration: InputDecoration(
                  hintText: TTexts.uiTextSearchBeat,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: TColors.softGrey,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.md),

            //--------------------------------------------------
            // Beat List
            //--------------------------------------------------
            Expanded(
              child: Obx(() {
                if (controller.dashboardBeatLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.dashboardFilteredBeats.isEmpty) {
                  return const Center(
                    child: Text(
                      TTexts.uiTextNoBeatsFound,
                      style: TextStyle(
                        color: TColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.md,
                    vertical: 8,
                  ),
                  itemCount: controller.dashboardFilteredBeats.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: TSizes.v12),
                  itemBuilder: (_, index) {
                    final beat = controller.dashboardFilteredBeats[index];
                    return Obx(() {
                      return _DashboardBeatTile(
                        beat: beat,
                        isCurrent: beat.id ==
                            controller.dashboardData.value?.data
                                ?.todayBeatAssigned?.beatId,
                        isSelected:
                            controller.dashboardSelectedBeat.value?.id ==
                                beat.id,
                        onTap: () {
                          controller.dashboardSelectedBeat.value = beat;

                          print(
                            "Selected : ${controller.dashboardSelectedBeat.value?.name}",
                          );
                        },
                      );
                    });
                  },
                );
              }),
            ),

            //--------------------------------------------------
            // Bottom Action
            //--------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TSizes.md,
                TSizes.sm,
                TSizes.md,
                TSizes.lg,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(
                            color: TColors.borderPrimary,
                          ),
                        ),
                        child: const Text(TTexts.cancel),
                      ),
                    ),
                    const SizedBox(width: TSizes.v14),
                    Expanded(
                      flex: 2,
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed:
                              controller.dashboardSelectedBeat.value == null
                                  ? null
                                  : () {
                                      // Close Bottom Sheet
                                      Get.back();

                                      // Open Reason Dialog
                                      Get.dialog(
                                        const DashboardBeatReasonDialog(),
                                        barrierDismissible: false,
                                      );
                                    },
                          icon: controller.dashboardBeatChanging.value
                              ? const SizedBox(
                                  width: TSizes.v18,
                                  height: TSizes.v18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: TSizes.v2,
                                    color: TColors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                ),
                          label: Text(
                            controller.dashboardBeatChanging.value
                                ? "Applying..."
                                : "Apply Beat",
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            elevation: TSizes.v0,
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//--------------------------------------------------
// Beat Tile Widget
//--------------------------------------------------
class _DashboardBeatTile extends StatelessWidget {
  final DashboardBeatModel beat;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;

  const _DashboardBeatTile({
    required this.beat,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewAreas = beat.areas.take(2).toList();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TColors.primary_shade50 : TColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? TColors.primary : TColors.borderPrimary,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.pureBlack.withOpacity(.04),
              blurRadius: TSizes.v10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------------------------------------
            // Selection
            //------------------------------------------------
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: TSizes.v24,
              height: TSizes.v24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? TColors.primary : TColors.white,
                border: Border.all(
                  color: isSelected ? TColors.primary : TColors.borderPrimary,
                  width: TSizes.v2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: TColors.white,
                      size: TSizes.v15,
                    )
                  : null,
            ),
            const SizedBox(width: TSizes.v16),

            //------------------------------------------------
            // Content
            //------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          beat.name,
                          style: const TextStyle(
                            fontSize: TSizes.v17,
                            fontWeight: FontWeight.w700,
                            color: TColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.successBg,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            TTexts.uiTextCURRENT,
                            style: TextStyle(
                              color: TColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: TSizes.v11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: TSizes.v8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: TSizes.v18,
                        color: TColors.primary,
                      ),
                      const SizedBox(width: TSizes.v6),
                      Text(
                        "${beat.areas.length} Area${beat.areas.length == 1 ? '' : 's'}",
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.v10),
                  Wrap(
                    spacing: TSizes.v8,
                    runSpacing: TSizes.v8,
                    children: [
                      ...previewAreas.map(
                        (area) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.softGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            area.name,
                            style: const TextStyle(
                              fontSize: TSizes.v12,
                              color: TColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (beat.areas.length > 2)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.primary_shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "+${beat.areas.length - 2} more",
                            style: const TextStyle(
                              color: TColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: TSizes.v12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
