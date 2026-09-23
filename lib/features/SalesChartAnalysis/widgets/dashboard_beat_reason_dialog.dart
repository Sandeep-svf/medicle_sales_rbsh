import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/DashboardController.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class DashboardBeatReasonDialog extends StatelessWidget {
  const DashboardBeatReasonDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_horiz_rounded,
              size: TSizes.v46,
              color: TColors.primary,
            ),

            const SizedBox(height: TSizes.v16),

            const Text(
              TTexts.uiTextChangeTodaySBeat,
              style: TextStyle(
                fontSize: TSizes.v21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: TSizes.v8),

            const Text(
              TTexts.uiTextPleaseProvideAValidReasonBeforeSubmittingThe,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColors.textSecondary,
              ),
            ),

            const SizedBox(height: TSizes.v24),
            //----------------------------------------------------------
            // Selected Beat
            //----------------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.primary_shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TColors.primary_shade100,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: TSizes.v46,
                    width: TSizes.v46,
                    decoration: const BoxDecoration(
                      color: TColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.route,
                      color: TColors.white,
                    ),
                  ),
                  const SizedBox(width: TSizes.v14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          TTexts.uiTextSelectedBeat,
                          style: TextStyle(
                            fontSize: TSizes.v12,
                            color: TColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: TSizes.v4),
                        Obx(
                          () => Text(
                            controller.dashboardSelectedBeat.value?.name ?? "-",
                            style: const TextStyle(
                              fontSize: TSizes.v17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.v22),

            //----------------------------------------------------------
            // Reason
            //----------------------------------------------------------

            TextField(
              controller: controller.dashboardBeatReasonController,
              maxLines: 4,
              maxLength: 250,
              decoration: InputDecoration(
                labelText: TTexts.uiTextReason_0c76fd5d,
                hintText: TTexts.uiTextExplainWhyYouWantToChangeTodayS,
                alignLabelWithHint: true,
                filled: true,
                fillColor: TColors.softGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: TColors.primary,
                    width: TSizes.v2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: TSizes.v8),
            //----------------------------------------------------------
            // Buttons
            //----------------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.dashboardBeatReasonController.clear();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(
                        color: TColors.borderPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(TTexts.cancel),
                  ),
                ),
                const SizedBox(width: TSizes.v12),
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: controller.dashboardBeatChanging.value
                          ? null
                          : () async {
                              final reason = controller
                                  .dashboardBeatReasonController.text
                                  .trim();

                              if (reason.isEmpty) {
                                Get.snackbar(
                                  "Reason Required",
                                  TTexts.uiTextPleaseEnterAValidReason,
                                );
                                return;
                              }

                              if (reason.length < 10) {
                                Get.snackbar(
                                  "Reason Too Short",
                                  TTexts
                                      .uiTextReasonShouldContainAtLeast10Characters,
                                );
                                return;
                              }

                              await controller.changeDashboardBeat(
                                reason: reason,
                              );
                            },
                      icon: controller.dashboardBeatChanging.value
                          ? const SizedBox(
                              height: TSizes.v18,
                              width: TSizes.v18,
                              child: CircularProgressIndicator(
                                strokeWidth: TSizes.v2,
                                color: TColors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        controller.dashboardBeatChanging.value
                            ? "Submitting..."
                            : "Submit Request",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
