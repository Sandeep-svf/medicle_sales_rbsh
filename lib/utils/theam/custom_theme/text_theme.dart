import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class STextTheme {
  STextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
        fontSize: TSizes.v32,
        fontWeight: FontWeight.bold,
        color: TColors.pureBlack),
    headlineMedium: const TextStyle().copyWith(
        fontSize: TSizes.v24,
        fontWeight: FontWeight.w600,
        color: TColors.pureBlack),
    headlineSmall: const TextStyle().copyWith(
        fontSize: TSizes.v18,
        fontWeight: FontWeight.w500,
        color: TColors.pureBlack),
    titleLarge: const TextStyle().copyWith(
        fontSize: TSizes.v16,
        fontWeight: FontWeight.w600,
        color: TColors.pureBlack),
    titleMedium: const TextStyle().copyWith(
        fontSize: TSizes.v16,
        fontWeight: FontWeight.w500,
        color: TColors.pureBlack),
    titleSmall: const TextStyle().copyWith(
        fontSize: TSizes.v16,
        fontWeight: FontWeight.w400,
        color: TColors.pureBlack),
    bodyLarge: const TextStyle().copyWith(
        fontSize: TSizes.v14,
        fontWeight: FontWeight.w500,
        color: TColors.pureBlack),
    bodyMedium: const TextStyle().copyWith(
        fontSize: TSizes.v14,
        fontWeight: FontWeight.normal,
        color: TColors.pureBlack),
    bodySmall: const TextStyle().copyWith(
        fontSize: TSizes.v14,
        fontWeight: FontWeight.w500,
        color: TColors.pureBlack.withOpacity(0.5)),
    labelLarge: const TextStyle().copyWith(
        fontSize: TSizes.v12,
        fontWeight: FontWeight.normal,
        color: TColors.pureBlack),
    labelMedium: const TextStyle().copyWith(
        fontSize: TSizes.v12,
        fontWeight: FontWeight.w500,
        color: TColors.pureBlack.withOpacity(0.5)),
  );
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
        fontSize: TSizes.v32,
        fontWeight: FontWeight.bold,
        color: TColors.white),
    headlineMedium: const TextStyle().copyWith(
        fontSize: TSizes.v24,
        fontWeight: FontWeight.w600,
        color: TColors.white),
    titleLarge: const TextStyle().copyWith(
        fontSize: TSizes.v16,
        fontWeight: FontWeight.w600,
        color: TColors.white),
    titleMedium: const TextStyle().copyWith(
        fontSize: TSizes.v16,
        fontWeight: FontWeight.w500,
        color: TColors.white),
    titleSmall: const TextStyle().copyWith(
        fontSize: TSizes.v16,
        fontWeight: FontWeight.w400,
        color: TColors.white),
    bodyLarge: const TextStyle().copyWith(
        fontSize: TSizes.v14,
        fontWeight: FontWeight.w500,
        color: TColors.white),
    bodyMedium: const TextStyle().copyWith(
        fontSize: TSizes.v14,
        fontWeight: FontWeight.normal,
        color: TColors.white),
    bodySmall: const TextStyle().copyWith(
        fontSize: TSizes.v14,
        fontWeight: FontWeight.w500,
        color: TColors.white.withOpacity(0.5)),
    labelLarge: const TextStyle().copyWith(
        fontSize: TSizes.v12,
        fontWeight: FontWeight.normal,
        color: TColors.white),
    labelMedium: const TextStyle().copyWith(
        fontSize: TSizes.v12,
        fontWeight: FontWeight.w500,
        color: TColors.white.withOpacity(0.5)),
  );
}
