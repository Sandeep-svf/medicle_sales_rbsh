import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class ExportReportButton extends StatelessWidget {
  const ExportReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: () {
              Get.snackbar("Note", TTexts.uiTextThisFeaturesIsInMaintenance);
            },
            child: const Text(TTexts.exportReport)),
      ),
    );
  }
}
