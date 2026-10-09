import '../../../../utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

String expense20Money(double amount) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
        .format(amount);

String expense20Type(String category) => switch (category) {
      'travel' => 'TA',
      'daily' => 'DA',
      'extra' => 'Other',
      _ => category,
    };

IconData expense20Icon(String category) => switch (category) {
      'travel' => Icons.directions_car_outlined,
      'daily' => Icons.restaurant_outlined,
      _ => Icons.receipt_long_outlined,
    };

Color expense20TypeColor(String category) => switch (category) {
      'daily' => TColors.allowanceFullText,
      'extra' => TColors.allowancePartialText,
      _ => TColors.primary,
    };

Color expense20TypeBackground(String category) => switch (category) {
      'daily' => TColors.allowanceFullBg,
      'extra' => TColors.allowancePartialBg,
      _ => TColors.primaryBackground,
    };

Color expense20StatusColor(String status) => switch (status.toLowerCase()) {
      'approved' => TColors.allowanceFullText,
      'rejected' => TColors.error,
      _ => TColors.allowancePartialText,
    };

Color expense20StatusBackground(String status) =>
    switch (status.toLowerCase()) {
      'approved' => TColors.allowanceFullBg,
      'rejected' => TColors.errorBg,
      _ => TColors.allowancePartialBg,
    };

class Expense20Status extends StatelessWidget {
  const Expense20Status(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: TSizes.v12, vertical: TSizes.v7),
        decoration: BoxDecoration(
          color: expense20StatusBackground(status),
          borderRadius: BorderRadius.circular(TSizes.v6),
        ),
        child: Text(
            status.isEmpty
                ? 'Pending'
                : '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}',
            style: TextStyle(
                color: expense20StatusColor(status),
                fontSize: TSizes.v12,
                fontWeight: FontWeight.w600)),
      );
}

class Expense20Panel extends StatelessWidget {
  const Expense20Panel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(TSizes.v20),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(TSizes.v14),
          border: Border.all(color: TColors.borderSecondary),
        ),
        child: child,
      );
}

class Expense20Heading extends StatelessWidget {
  const Expense20Heading(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon,
      this.action});
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            padding: const EdgeInsets.all(TSizes.v10),
            decoration: BoxDecoration(
                color: TColors.primaryBackground,
                borderRadius: BorderRadius.circular(TSizes.v10)),
            child: Icon(icon, color: TColors.primary, size: TSizes.v24)),
        const SizedBox(width: TSizes.v12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: TColors.primary,
                  fontSize: TSizes.v17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: TSizes.v3),
          Text(subtitle,
              style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: TSizes.v12,
                  height: TSizes.v1_4)),
        ])),
        if (action != null) ...[const SizedBox(width: TSizes.v8), action!],
      ]);
}

InputDecoration expense20Input(String hint, {Widget? prefix, Widget? suffix}) =>
    InputDecoration(
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: TColors.white,
      hintStyle: const TextStyle(color: TColors.darkGrey, fontSize: TSizes.v12),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: TSizes.v12, vertical: TSizes.v14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.v7),
          borderSide: const BorderSide(color: TColors.borderPrimary)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.v7),
          borderSide: const BorderSide(color: TColors.borderSecondary)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.v7),
          borderSide: const BorderSide(color: TColors.primary)),
    );

Widget expense20Label(String text, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: const TextStyle(
                color: TColors.textPrimary,
                fontSize: TSizes.v12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: TSizes.v7),
        child,
      ],
    );

Widget expense20Pair(Widget left, Widget right, {double gap = TSizes.v12}) =>
    LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= TSizes.v360
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: left),
                SizedBox(width: gap),
                Expanded(child: right)
              ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [left, SizedBox(height: gap), right]));

void expense20Message(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: TColors.white)),
      backgroundColor: TColors.primary,
    ));
}
