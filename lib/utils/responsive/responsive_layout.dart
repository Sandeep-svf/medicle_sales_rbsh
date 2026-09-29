import 'package:flutter/material.dart';

/// Device form factor is based on the shortest side, so a phone remains a
/// phone when rotated into landscape.
class TResponsive {
  const TResponsive._();

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide < 600;

  /// Use available width for layouts that must stack in narrow viewports.
  static bool isNarrow(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;
}
