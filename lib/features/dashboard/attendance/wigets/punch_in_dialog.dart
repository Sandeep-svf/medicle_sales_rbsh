import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../controller/attendance_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class PunchInDialog extends GetView<AttendanceController> {
  const PunchInDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Icon
                Container(
                  width: TSizes.v72,
                  height: TSizes.v72,
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    color: TColors.primary,
                    size: TSizes.v40,
                  ),
                ),

                const SizedBox(height: TSizes.v20),

                const Text(
                  TTexts.uiTextGoodMorning,
                  style: TextStyle(
                    fontSize: TSizes.v22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: TSizes.v10),

                Text(
                  DateTime.now().toString().split(" ").first,
                  style: TextStyle(
                    color: TColors.materialGrey600,
                    fontSize: TSizes.v14,
                  ),
                ),

                const SizedBox(height: TSizes.v25),

                const Text(
                  TTexts.uiTextPleasePunchInToContinueUsingTheApplication,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: TSizes.v15,
                    height: TSizes.v1_5,
                  ),
                ),

                const SizedBox(height: TSizes.v30),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.materialGrey100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          TTexts.uiTextPunchIn,
                          style: TextStyle(
                            fontSize: TSizes.v17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      controller.isPunching.value
                          ? const SizedBox(
                              width: TSizes.v28,
                              height: TSizes.v28,
                              child: CircularProgressIndicator(
                                strokeWidth: TSizes.v3,
                              ),
                            )
                          : CupertinoSwitch(
                              value: false,
                              activeColor: TColors.primary,
                              onChanged: (value) async {
                                if (!value) return;

                                await controller.punchIn();
                              },
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: TSizes.v18),

                Text(
                  TTexts.uiTextAttendanceIsRequiredBeforeAccessingTheDashboard,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColors.materialGrey600,
                    fontSize: TSizes.v12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
