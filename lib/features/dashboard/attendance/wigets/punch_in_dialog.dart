import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../controller/attendance_controller.dart';

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
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    color: TColors.primary,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Good Morning 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  DateTime.now().toString().split(" ").first,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Please Punch In to continue using the application.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [

                      const Expanded(
                        child: Text(
                          "Punch In",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      controller.isPunching.value
                          ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
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

                const SizedBox(height: 18),

                Text(
                  "Attendance is required before accessing the dashboard.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
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