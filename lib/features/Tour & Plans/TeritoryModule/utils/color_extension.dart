import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
// color_extension.dart

import 'package:flutter/material.dart';

extension HexColorExtension on String {
  Color toColor() {
    try {
      return Color(
        int.parse(
          replaceFirst('#', '0xFF'),
        ),
      );
    } catch (_) {
      return TColors.materialRed;
    }
  }
}
