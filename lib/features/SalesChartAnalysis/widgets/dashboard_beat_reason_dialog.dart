import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../controller/DashboardController.dart';

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
    size: 46,
    color: TColors.primary,
    ),

    const SizedBox(height: 16),

    const Text(
    "Change Today's Beat",
    style: TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.bold,
    ),
    ),

    const SizedBox(height: 8),

    const Text(
    "Please provide a valid reason before submitting the beat change request.",
    textAlign: TextAlign.center,
    style: TextStyle(
    color: TColors.textSecondary,
    ),
    ),

    const SizedBox(height: 24),
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
    height: 46,
    width: 46,
    decoration: const BoxDecoration(
    color: TColors.primary,
    shape: BoxShape.circle,
    ),
    child: const Icon(
    Icons.route,
    color: Colors.white,
    ),
    ),

    const SizedBox(width: 14),

    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

    const Text(
    "Selected Beat",
    style: TextStyle(
    fontSize: 12,
    color: TColors.textSecondary,
    ),
    ),

    const SizedBox(height: 4),

    Obx(
    () => Text(
    controller.dashboardSelectedBeat.value?.name ??
    "-",
    style: const TextStyle(
    fontSize: 17,
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

    const SizedBox(height: 22),

    //----------------------------------------------------------
    // Reason
    //----------------------------------------------------------

    TextField(
    controller: controller.dashboardBeatReasonController,
    maxLines: 4,
    maxLength: 250,
    decoration: InputDecoration(
    labelText: "Reason *",
    hintText:
    "Explain why you want to change today's assigned beat...",
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
    width: 2,
    ),
    ),
    ),
    ),

    const SizedBox(height: 8),
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
              child: const Text("Cancel"),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: Obx(
                  () => ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
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
                      "Please enter a valid reason.",
                    );
                    return;
                  }

                  if (reason.length < 10) {
                    Get.snackbar(
                      "Reason Too Short",
                      "Reason should contain at least 10 characters.",
                    );
                    return;
                  }

                  await controller.changeDashboardBeat(
                    reason: reason,
                  );
                },
                icon: controller.dashboardBeatChanging.value
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
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