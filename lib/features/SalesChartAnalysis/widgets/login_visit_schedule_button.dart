import 'package:flutter/material.dart';

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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text(
              TTexts.loginActivity,
            )),

        /// Schedule Visit Button
        ElevatedButton(
            onPressed: () {},
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