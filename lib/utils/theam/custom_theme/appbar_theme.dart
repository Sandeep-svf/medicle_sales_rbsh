import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class SAppBarTheme {
  SAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: TSizes.v0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.transparent,
    surfaceTintColor: TColors.transparent,
    iconTheme: IconThemeData(color: TColors.black, size: TSizes.iconMd),
    actionsIconTheme: IconThemeData(color: TColors.black, size: TSizes.iconMd),
    titleTextStyle: TextStyle(
        fontSize: TSizes.v18,
        fontWeight: FontWeight.w600,
        color: TColors.black),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: TSizes.v0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.transparent,
    surfaceTintColor: TColors.transparent,
    iconTheme: IconThemeData(color: TColors.black, size: TSizes.iconMd),
    actionsIconTheme: IconThemeData(color: TColors.white, size: TSizes.iconMd),
    titleTextStyle: TextStyle(
        fontSize: TSizes.v18,
        fontWeight: FontWeight.w600,
        color: TColors.white),
  );
}
