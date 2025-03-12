import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:medicle_sales_rbsh/features/salesActivity/screens/salesActivity.dart';
import 'package:medicle_sales_rbsh/features/visitDoctor/screens/visitDoctor.dart';
import '../../../utils/constants/text_strings.dart';

class LoginViistScheduleButton extends StatelessWidget {
  const LoginViistScheduleButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        /// LoginActivityButton
        ElevatedButton(
            onPressed: ()  => Get.to( const SalesactivityScreen()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text(
              TTexts.loginActivity,
            )),

        /// Schedule Visit Button
        ElevatedButton(
            onPressed: () => Get.to( const VisitDoctorScreen()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text(
              TTexts.scheduleVisit,
            )),
      ],
    );
  }
}