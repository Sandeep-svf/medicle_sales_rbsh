import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart'; // Ensure this path matches your project

class AppColors {
  // Main Theme
  static const Color primaryDark = TColors.primary; // Mapped to your 0xFFC71D52
  static const Color background = TColors.light;
  static const Color cardWhite = TColors.white;

  // Typography
  static const Color textMain = TColors.textPrimary;
  static const Color textMuted = TColors.textSecondary;

  // Unassigned Days (Uses your error color and your lightest primary shade)
  static const Color unassignedBorder = TColors.error;
  static const Color unassignedBg = TColors.primary_shade50;

  // Holidays
  static const Color holidayBg = TColors.softGrey;
  static const Color holidayText = TColors.warning;

  // Assigned Beats
  static const Color beatBg = TColors.white;
  static const Color beatText = TColors.primary_shade700; // Darker primary for readable text

  // Approved Leaves (Uses your info color to distinguish from primary actions)
  static const Color leaveBg = Color(0xFFE3F2FD); // Soft info background
  static const Color leaveText = TColors.info;

  // Validation Modal Statuses
  static const Color warningOrange = TColors.warning;
  static const Color successGreen = TColors.success;
}