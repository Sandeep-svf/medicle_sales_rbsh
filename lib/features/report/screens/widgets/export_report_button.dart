import 'package:flutter/material.dart';

import '../../../../utils/constants/text_strings.dart';

class ExportReportButton extends StatelessWidget {
  const ExportReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: (){}, child: const Text(TTexts.exportReport)),
      ),
    );
  }
}
