import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class AllowanceStatusStyle {
  static Color foreground(int payablePercent) => payablePercent == 0
      ? TColors.error
      : payablePercent == 50
          ? TColors.allowancePartialText
          : TColors.allowanceFullText;

  static Color background(int payablePercent) => payablePercent == 0
      ? TColors.errorBg
      : payablePercent == 50
          ? TColors.allowancePartialBg
          : TColors.allowanceFullBg;

  static String label(int payablePercent) => payablePercent == 0
      ? 'Not eligible'
      : payablePercent == 50
          ? 'Partial allowance'
          : 'Full allowance';
}
