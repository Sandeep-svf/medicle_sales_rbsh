import 'package:flutter/material.dart';

/*class TColors {
  // App theme colors
  static const Color primary = Color(0xFFC71D52);
  static const Color primary_shade100 = Color(0xFFFFCDD7);

  // static const Color primary = Color(0xFFC71D52);

  static const Color primary_shade50 = Color(0xFFFDE8EE);
  // static const Color primary_shade100 = Color(0xFFFFCDD7);
  static const Color primary_shade200 = Color(0xFFF499B1);
  static const Color primary_shade300 = Color(0xFFE8648A);
  static const Color primary_shade400 = Color(0xFFD63B6B);
  static const Color primary_shade500 = Color(0xFFC71D52); // Primary
  static const Color primary_shade600 = Color(0xFFA81643);
  static const Color primary_shade700 = Color(0xFF8A1035);
  static const Color primary_shade800 = Color(0xFF6E0928);
  static const Color primary_shade900 = Color(0xFF50041B);

  // Shadow colors with opacity (if you meant actual shadows for elevation)
  static const Color primary_shadow_light = Color(0x4DC71D52); // 30% opacity
  static const Color primary_shadow_dark = Color(0x80C71D52); // 50% opacity

  //static const Color primary = Color(0xFF4b68ff);
  static const Color secondary = Color(0xFFEFA100);
  static const Color accent = Color(0xFFb0c7ff);

  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Background colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  // Background Container colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = TColors.white.withOpacity(0.1);

  // Button colors
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);

  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF0D7E0);

// Soft backgrounds
  static const Color cardPink = Color(0xFFFDE8EE);
  static const Color cardPinkLight = Color(0xFFFFF5F8);

// Status Colors
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color errorBg = Color(0xFFFFEBEE);

// Travel & Allowance
  static const Color travelBg = Color(0xFFFDE8EE);
  static const Color allowanceBg = Color(0xFFFFF5E8);

// Icon Containers
  static const Color iconBg = Color(0xFFFDE8EE);

// Amount Text
  static const Color amountText = Color(0xFF8A1035);

  // Flutter palette aliases. Keeping these values here lets every screen use
  // one project color source without changing the current UI.
  static const Color transparent = Color(0x00000000);
  static const Color pureBlack = Color(0xFF000000);
  static const Color black12 = Color(0x1F000000);
  static const Color black26 = Color(0x42000000);
  static const Color black38 = Color(0x61000000);
  static const Color black45 = Color(0x73000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black87 = Color(0xDE000000);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color materialGrey = Color(0xFF9E9E9E);
  static const Color materialGrey50 = Color(0xFFFAFAFA);
  static const Color materialGrey100 = Color(0xFFF5F5F5);
  static const Color materialGrey200 = Color(0xFFEEEEEE);
  static const Color materialGrey300 = Color(0xFFE0E0E0);
  static const Color materialGrey400 = Color(0xFFBDBDBD);
  static const Color materialGrey500 = Color(0xFF9E9E9E);
  static const Color materialGrey600 = Color(0xFF757575);
  static const Color materialGrey700 = Color(0xFF616161);
  static const Color materialGrey800 = Color(0xFF424242);
  static const Color materialGrey900 = Color(0xFF212121);
  static const Color materialRed = Color(0xFFF44336);
  static const Color materialRedAccent = Color(0xFFFF5252);
  static const Color materialRed50 = Color(0xFFFFEBEE);
  static const Color materialRed100 = Color(0xFFFFCDD2);
  static const Color materialRed200 = Color(0xFFEF9A9A);
  static const Color materialRed300 = Color(0xFFE57373);
  static const Color materialRed400 = Color(0xFFEF5350);
  static const Color materialRed500 = Color(0xFFF44336);
  static const Color materialRed600 = Color(0xFFE53935);
  static const Color materialRed700 = Color(0xFFD32F2F);
  static const Color materialRed800 = Color(0xFFC62828);
  static const Color materialRed900 = Color(0xFFB71C1C);
  static const Color materialGreen = Color(0xFF4CAF50);
  static const Color materialGreenAccent = Color(0xFF69F0AE);
  static const Color materialGreen50 = Color(0xFFE8F5E9);
  static const Color materialGreen100 = Color(0xFFC8E6C9);
  static const Color materialGreen200 = Color(0xFFA5D6A7);
  static const Color materialGreen300 = Color(0xFF81C784);
  static const Color materialGreen400 = Color(0xFF66BB6A);
  static const Color materialGreen500 = Color(0xFF4CAF50);
  static const Color materialGreen600 = Color(0xFF43A047);
  static const Color materialGreen700 = Color(0xFF388E3C);
  static const Color materialGreen800 = Color(0xFF2E7D32);
  static const Color materialGreen900 = Color(0xFF1B5E20);
  static const Color materialBlue = Color(0xFF2196F3);
  static const Color materialBlueAccent = Color(0xFF448AFF);
  static const Color materialBlueGrey = Color(0xFF607D8B);
  static const Color materialBlue50 = Color(0xFFE3F2FD);
  static const Color materialBlue100 = Color(0xFFBBDEFB);
  static const Color materialBlue200 = Color(0xFF90CAF9);
  static const Color materialBlue300 = Color(0xFF64B5F6);
  static const Color materialBlue400 = Color(0xFF42A5F5);
  static const Color materialBlue500 = Color(0xFF2196F3);
  static const Color materialBlue600 = Color(0xFF1E88E5);
  static const Color materialBlue700 = Color(0xFF1976D2);
  static const Color materialBlue800 = Color(0xFF1565C0);
  static const Color materialBlue900 = Color(0xFF0D47A1);
  static const Color materialOrange = Color(0xFFFF9800);
  static const Color materialOrangeAccent = Color(0xFFFFAB40);
  static const Color materialOrange50 = Color(0xFFFFF3E0);
  static const Color materialOrange100 = Color(0xFFFFE0B2);
  static const Color materialOrange200 = Color(0xFFFFCC80);
  static const Color materialOrange300 = Color(0xFFFFB74D);
  static const Color materialOrange400 = Color(0xFFFFA726);
  static const Color materialOrange500 = Color(0xFFFF9800);
  static const Color materialOrange600 = Color(0xFFFB8C00);
  static const Color materialOrange700 = Color(0xFFF57C00);
  static const Color materialOrange800 = Color(0xFFEF6C00);
  static const Color materialOrange900 = Color(0xFFE65100);
  static const Color materialAmber = Color(0xFFFFC107);
  static const Color materialAmber50 = Color(0xFFFFF8E1);
  static const Color materialAmber100 = Color(0xFFFFECB3);
  static const Color materialAmber200 = Color(0xFFFFE082);
  static const Color materialAmber300 = Color(0xFFFFD54F);
  static const Color materialAmber400 = Color(0xFFFFCA28);
  static const Color materialAmber500 = Color(0xFFFFC107);
  static const Color materialAmber600 = Color(0xFFFFB300);
  static const Color materialAmber700 = Color(0xFFFFA000);
  static const Color materialAmber800 = Color(0xFFFF8F00);
  static const Color materialAmber900 = Color(0xFFFF6F00);
  static const Color materialDeepOrange = Color(0xFFFF5722);
  static const Color materialDeepPurple = Color(0xFF673AB7);
  static const Color materialDeepPurpleAccent = Color(0xFF7C4DFF);
  static const Color materialPurple = Color(0xFF9C27B0);
  static const Color materialPurpleAccent = Color(0xFFE040FB);
  static const Color materialPink = Color(0xFFE91E63);
  static const Color materialIndigo = Color(0xFF3F51B5);
  static const Color materialTeal = Color(0xFF009688);
  static const Color materialCyan = Color(0xFF00BCD4);
  static const Color materialBrown = Color(0xFF795548);
  static const Color materialYellow = Color(0xFFFFEB3B);

  // Screen-specific values moved here with their original RGB values.
  static const Color hex_40000000 = Color(0x40000000);
  static const Color hex_FF009688 = Color(0xFF009688);
  static const Color hex_FF0F172A = Color(0xFF0F172A);
  static const Color hex_FF0F2027 = Color(0xFF0F2027);
  static const Color hex_FF1565C0 = Color(0xFF1565C0);
  static const Color hex_FF1E1E2C = Color(0xFF1E1E2C);
  static const Color hex_FF1E293B = Color(0xFF1E293B);
  static const Color hex_FF203A43 = Color(0xFF203A43);
  static const Color hex_FF2196F3 = Color(0xFF2196F3);
  static const Color hex_FF263238 = Color(0xFF263238);
  static const Color hex_FF2C3E50 = Color(0xFF2C3E50);
  static const Color hex_FF2C5364 = Color(0xFF2C5364);
  static const Color hex_FF2D0E15 = Color(0xFF2D0E15);
  static const Color hex_FF2D3436 = Color(0xFF2D3436);
  static const Color hex_FF2E7D32 = Color(0xFF2E7D32);
  static const Color hex_FF333333 = Color(0xFF333333);
  static const Color hex_FF334155 = Color(0xFF334155);
  static const Color hex_FF475569 = Color(0xFF475569);
  static const Color hex_FF4B68FF = Color(0xFF4B68FF);
  static const Color hex_FF50041B = Color(0xFF50041B);
  static const Color hex_FF636E72 = Color(0xFF636E72);
  static const Color hex_FF64748B = Color(0xFF64748B);
  static const Color hex_FF744210 = Color(0xFF744210);
  static const Color hex_FF8A1035 = Color(0xFF8A1035);
  static const Color hex_FF8E8E8E = Color(0xFF8E8E8E);
  static const Color hex_FF94A3B8 = Color(0xFF94A3B8);
  static const Color hex_FF9E9E9E = Color(0xFF9E9E9E);
  static const Color hex_FFB7791F = Color(0xFFB7791F);
  static const Color hex_FFC62828 = Color(0xFFC62828);
  static const Color hex_FFC71D52 = Color(0xFFC71D52);
  static const Color hex_FFE0EAFC = Color(0xFFE0EAFC);
  static const Color hex_FFE2E8F0 = Color(0xFFE2E8F0);
  static const Color hex_FFE3F2FD = Color(0xFFE3F2FD);
  static const Color hex_FFE5F1FB = Color(0xFFE5F1FB);
  static const Color hex_FFE8F5E1 = Color(0xFFE8F5E1);
  static const Color hex_FFE8F5E9 = Color(0xFFE8F5E9);
  static const Color hex_FFEAF2FF = Color(0xFFEAF2FF);
  static const Color hex_FFEDE6E9 = Color(0xFFEDE6E9);
  static const Color hex_FFEF6C00 = Color(0xFFEF6C00);
  static const Color hex_FFEFA100 = Color(0xFFEFA100);
  static const Color hex_FFF0F0F0 = Color(0xFFF0F0F0);
  static const Color hex_FFF0F2F5 = Color(0xFFF0F2F5);
  static const Color hex_FFF1F3F5 = Color(0xFFF1F3F5);
  static const Color hex_FFF1F4F9 = Color(0xFFF1F4F9);
  static const Color hex_FFF1F5F9 = Color(0xFFF1F5F9);
  static const Color hex_FFF499B1 = Color(0xFFF499B1);
  static const Color hex_FFF4F6F9 = Color(0xFFF4F6F9);
  static const Color hex_FFF5F5F5 = Color(0xFFF5F5F5);
  static const Color hex_FFF5F7FA = Color(0xFFF5F7FA);
  static const Color hex_FFF6F7FB = Color(0xFFF6F7FB);
  static const Color hex_FFF7F8FC = Color(0xFFF7F8FC);
  static const Color hex_FFF7F9FC = Color(0xFFF7F9FC);
  static const Color hex_FFF8F5F6 = Color(0xFFF8F5F6);
  static const Color hex_FFF8F6F7 = Color(0xFFF8F6F7);
  static const Color hex_FFF8FAFC = Color(0xFFF8FAFC);
  static const Color hex_FFF9A825 = Color(0xFFF9A825);
  static const Color hex_FFFAF8F9 = Color(0xFFFAF8F9);
  static const Color hex_FFFAFAFA = Color(0xFFFAFAFA);
  static const Color hex_FFFBC02D = Color(0xFFFBC02D);
  static const Color hex_FFFF6D00 = Color(0xFFFF6D00);
  static const Color hex_FFFFE2E2 = Color(0xFFFFE2E2);
  static const Color hex_FFFFE9DA = Color(0xFFFFE9DA);
  static const Color hex_FFFFEBEE = Color(0xFFFFEBEE);
  static const Color hex_FFFFF3E0 = Color(0xFFFFF3E0);
  static const Color hex_FFFFF5D6 = Color(0xFFFFF5D6);
}*/

import 'package:flutter/material.dart';

class TColors {
  // FieldOmni brand colors
  static const Color secondary = Color(0xFF00C8B6);
  static const Color primary_shade50 = Color(0xFFF0FCFA);
  static const Color primary_shade100 = Color(0xFFD7F7F2);
  static const Color primary_shade200 = Color(0xFFA9EFE6);
  static const Color primary_shade300 = Color(0xFF6DE2D5);
  static const Color primary_shade400 = Color(0xFF2AD3C3);
  static const Color primary_shade500 = Color(0xFF00C8B6);
  static const Color primary_shade600 = Color(0xFF00AA9A);
  static const Color primary_shade700 = Color(0xFF008B7E);
  static const Color primary_shade800 = Color(0xFF006E64);
  static const Color primary_shade900 = Color(0xFF005047);

  static const Color primary_shadow_light = Color(0x4D00C8B6);
  static const Color primary_shadow_dark = Color(0x8000C8B6);

  static const Color  primary = Color(0xFF013952);
  static const Color accent = Color(0xFFA9EFE6);

  // Text colors
  static const Color textPrimary = Color(0xFF013952);
  static const Color textSecondary = Color(0xFF52707D);
  static const Color textWhite = Colors.white;

  // Background colors
  static const Color light = Color(0xFFF6FBFB);
  static const Color dark = Color(0xFF013952);
  static const Color primaryBackground = Color(0xFFF0FCFA);

  // Background Container colors
  static const Color lightContainer = Color(0xFFF6FBFB);
  static Color darkContainer = TColors.white.withOpacity(0.1);

  // Button colors
  static const Color buttonPrimary = Color(0xFF00C8B6);
  static const Color buttonSecondary = Color(0xFF52707D);
  static const Color buttonDisabled = Color(0xFFC5DADF);

  // Border colors
  static const Color borderPrimary = Color(0xFFC5DADF);
  static const Color borderSecondary = Color(0xFFE4EFF1);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF008B7E);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF013952);

  // Neutral Shades
  static const Color black = Color(0xFF013952);
  static const Color darkerGrey = Color(0xFF2C586A);
  static const Color darkGrey = Color(0xFF7896A1);
  static const Color grey = Color(0xFFC5DADF);
  static const Color softGrey = Color(0xFFF0F7F7);
  static const Color lightGrey = Color(0xFFF8FCFC);
  static const Color white = Color(0xFFFFFFFF);

  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFD7F7F2);

  // Soft backgrounds
  static const Color cardPink = Color(0xFFF0FCFA);
  static const Color cardPinkLight = Color(0xFFF8FEFD);

  // Status Colors
  static const Color successBg = Color(0xFFD7F7F2);
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color errorBg = Color(0xFFFFEBEE);

  // Travel & Allowance
  static const Color travelBg = Color(0xFFF0FCFA);
  static const Color allowanceBg = Color(0xFFE4F7F5);

  // Icon Containers
  static const Color iconBg = Color(0xFFD7F7F2);

  // Amount Text
  static const Color amountText = Color(0xFF006E64);

  // Flutter palette aliases
  static const Color transparent = Color(0x00000000);
  static const Color pureBlack = Color(0xFF000000);
  static const Color black12 = Color(0x1F000000);
  static const Color black26 = Color(0x42000000);
  static const Color black38 = Color(0x61000000);
  static const Color black45 = Color(0x73000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black87 = Color(0xDE000000);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);

  static const Color materialGrey = Color(0xFF7896A1);
  static const Color materialGrey50 = Color(0xFFF8FCFC);
  static const Color materialGrey100 = Color(0xFFF0F7F7);
  static const Color materialGrey200 = Color(0xFFE4EFF1);
  static const Color materialGrey300 = Color(0xFFC5DADF);
  static const Color materialGrey400 = Color(0xFFA1BBC3);
  static const Color materialGrey500 = Color(0xFF7896A1);
  static const Color materialGrey600 = Color(0xFF52707D);
  static const Color materialGrey700 = Color(0xFF2C586A);
  static const Color materialGrey800 = Color(0xFF16465D);
  static const Color materialGrey900 = Color(0xFF013952);

  // Keep semantic colors distinct for validation/status UI.
  static const Color materialRed = Color(0xFFD32F2F);
  static const Color materialRedAccent = Color(0xFFFF5252);
  static const Color materialRed50 = Color(0xFFFFEBEE);
  static const Color materialRed100 = Color(0xFFFFCDD2);
  static const Color materialRed200 = Color(0xFFEF9A9A);
  static const Color materialRed300 = Color(0xFFE57373);
  static const Color materialRed400 = Color(0xFFEF5350);
  static const Color materialRed500 = Color(0xFFF44336);
  static const Color materialRed600 = Color(0xFFE53935);
  static const Color materialRed700 = Color(0xFFD32F2F);
  static const Color materialRed800 = Color(0xFFC62828);
  static const Color materialRed900 = Color(0xFFB71C1C);

  static const Color materialGreen = Color(0xFF00C8B6);
  static const Color materialGreenAccent = Color(0xFF6DE2D5);
  static const Color materialGreen50 = Color(0xFFF0FCFA);
  static const Color materialGreen100 = Color(0xFFD7F7F2);
  static const Color materialGreen200 = Color(0xFFA9EFE6);
  static const Color materialGreen300 = Color(0xFF6DE2D5);
  static const Color materialGreen400 = Color(0xFF2AD3C3);
  static const Color materialGreen500 = Color(0xFF00C8B6);
  static const Color materialGreen600 = Color(0xFF00AA9A);
  static const Color materialGreen700 = Color(0xFF008B7E);
  static const Color materialGreen800 = Color(0xFF006E64);
  static const Color materialGreen900 = Color(0xFF005047);

  static const Color materialBlue = Color(0xFF013952);
  static const Color materialBlueAccent = Color(0xFF176277);
  static const Color materialBlueGrey = Color(0xFF52707D);
  static const Color materialBlue50 = Color(0xFFF4FAFA);
  static const Color materialBlue100 = Color(0xFFE4EFF1);
  static const Color materialBlue200 = Color(0xFFC5DADF);
  static const Color materialBlue300 = Color(0xFFA1BBC3);
  static const Color materialBlue400 = Color(0xFF7896A1);
  static const Color materialBlue500 = Color(0xFF52707D);
  static const Color materialBlue600 = Color(0xFF2C586A);
  static const Color materialBlue700 = Color(0xFF16465D);
  static const Color materialBlue800 = Color(0xFF0A435C);
  static const Color materialBlue900 = Color(0xFF013952);

  static const Color materialOrange = Color(0xFF00AA9A);
  static const Color materialOrangeAccent = Color(0xFF2AD3C3);
  static const Color materialOrange50 = Color(0xFFF0FCFA);
  static const Color materialOrange100 = Color(0xFFD7F7F2);
  static const Color materialOrange200 = Color(0xFFA9EFE6);
  static const Color materialOrange300 = Color(0xFF6DE2D5);
  static const Color materialOrange400 = Color(0xFF2AD3C3);
  static const Color materialOrange500 = Color(0xFF00C8B6);
  static const Color materialOrange600 = Color(0xFF00AA9A);
  static const Color materialOrange700 = Color(0xFF008B7E);
  static const Color materialOrange800 = Color(0xFF006E64);
  static const Color materialOrange900 = Color(0xFF005047);

  static const Color materialAmber = Color(0xFF00C8B6);
  static const Color materialAmber50 = Color(0xFFF0FCFA);
  static const Color materialAmber100 = Color(0xFFD7F7F2);
  static const Color materialAmber200 = Color(0xFFA9EFE6);
  static const Color materialAmber300 = Color(0xFF6DE2D5);
  static const Color materialAmber400 = Color(0xFF2AD3C3);
  static const Color materialAmber500 = Color(0xFF00C8B6);
  static const Color materialAmber600 = Color(0xFF00AA9A);
  static const Color materialAmber700 = Color(0xFF008B7E);
  static const Color materialAmber800 = Color(0xFF006E64);
  static const Color materialAmber900 = Color(0xFF005047);

  static const Color materialDeepOrange = Color(0xFF008B7E);
  static const Color materialDeepPurple = Color(0xFF013952);
  static const Color materialDeepPurpleAccent = Color(0xFF176277);
  static const Color materialPurple = Color(0xFF2C586A);
  static const Color materialPurpleAccent = Color(0xFF52707D);
  static const Color materialPink = Color(0xFF00C8B6);
  static const Color materialIndigo = Color(0xFF013952);
  static const Color materialTeal = Color(0xFF00C8B6);
  static const Color materialCyan = Color(0xFF2AD3C3);
  static const Color materialBrown = Color(0xFF2C586A);
  static const Color materialYellow = Color(0xFFA9EFE6);

  // Existing generated names retained.
  static const Color hex_40000000 = Color(0x40000000);
  static const Color hex_FF009688 = Color(0xFF00C8B6);
  static const Color hex_FF0F172A = Color(0xFF013952);
  static const Color hex_FF0F2027 = Color(0xFF013952);
  static const Color hex_FF1565C0 = Color(0xFF16465D);
  static const Color hex_FF1E1E2C = Color(0xFF013952);
  static const Color hex_FF1E293B = Color(0xFF16465D);
  static const Color hex_FF203A43 = Color(0xFF013952);
  static const Color hex_FF2196F3 = Color(0xFF013952);
  static const Color hex_FF263238 = Color(0xFF16465D);
  static const Color hex_FF2C3E50 = Color(0xFF013952);
  static const Color hex_FF2C5364 = Color(0xFF2C586A);
  static const Color hex_FF2D0E15 = Color(0xFF013952);
  static const Color hex_FF2D3436 = Color(0xFF16465D);
  static const Color hex_FF2E7D32 = Color(0xFF008B7E);
  static const Color hex_FF333333 = Color(0xFF013952);
  static const Color hex_FF334155 = Color(0xFF2C586A);
  static const Color hex_FF475569 = Color(0xFF52707D);
  static const Color hex_FF4B68FF = Color(0xFF00C8B6);
  static const Color hex_FF50041B = Color(0xFF005047);
  static const Color hex_FF636E72 = Color(0xFF52707D);
  static const Color hex_FF64748B = Color(0xFF52707D);
  static const Color hex_FF744210 = Color(0xFF006E64);
  static const Color hex_FF8A1035 = Color(0xFF006E64);
  static const Color hex_FF8E8E8E = Color(0xFF7896A1);
  static const Color hex_FF94A3B8 = Color(0xFFA1BBC3);
  static const Color hex_FF9E9E9E = Color(0xFF7896A1);
  static const Color hex_FFB7791F = Color(0xFF008B7E);
  static const Color hex_FFC62828 = Color(0xFFD32F2F);
  static const Color hex_FFC71D52 = Color(0xFF00C8B6);
  static const Color hex_FFE0EAFC = Color(0xFFE4EFF1);
  static const Color hex_FFE2E8F0 = Color(0xFFE4EFF1);
  static const Color hex_FFE3F2FD = Color(0xFFF0FCFA);
  static const Color hex_FFE5F1FB = Color(0xFFF0FCFA);
  static const Color hex_FFE8F5E1 = Color(0xFFD7F7F2);
  static const Color hex_FFE8F5E9 = Color(0xFFD7F7F2);
  static const Color hex_FFEAF2FF = Color(0xFFF0FCFA);
  static const Color hex_FFEDE6E9 = Color(0xFFE4EFF1);
  static const Color hex_FFEF6C00 = Color(0xFF008B7E);
  static const Color hex_FFEFA100 = Color(0xFF00AA9A);
  static const Color hex_FFF0F0F0 = Color(0xFFF0F7F7);
  static const Color hex_FFF0F2F5 = Color(0xFFF0F7F7);
  static const Color hex_FFF1F3F5 = Color(0xFFF0F7F7);
  static const Color hex_FFF1F4F9 = Color(0xFFF4FAFA);
  static const Color hex_FFF1F5F9 = Color(0xFFF4FAFA);
  static const Color hex_FFF499B1 = Color(0xFFA9EFE6);
  static const Color hex_FFF4F6F9 = Color(0xFFF4FAFA);
  static const Color hex_FFF5F5F5 = Color(0xFFF0F7F7);
  static const Color hex_FFF5F7FA = Color(0xFFF4FAFA);
  static const Color hex_FFF6F7FB = Color(0xFFF6FBFB);
  static const Color hex_FFF7F8FC = Color(0xFFF8FCFC);
  static const Color hex_FFF7F9FC = Color(0xFFF8FCFC);
  static const Color hex_FFF8F5F6 = Color(0xFFF8FCFC);
  static const Color hex_FFF8F6F7 = Color(0xFFF8FCFC);
  static const Color hex_FFF8FAFC = Color(0xFFF8FCFC);
  static const Color hex_FFF9A825 = Color(0xFF00AA9A);
  static const Color hex_FFFAF8F9 = Color(0xFFF8FCFC);
  static const Color hex_FFFAFAFA = Color(0xFFF8FCFC);
  static const Color hex_FFFBC02D = Color(0xFF00C8B6);
  static const Color hex_FFFF6D00 = Color(0xFF008B7E);
  static const Color hex_FFFFE2E2 = Color(0xFFFFEBEE);
  static const Color hex_FFFFE9DA = Color(0xFFF0FCFA);
  static const Color hex_FFFFEBEE = Color(0xFFFFEBEE);
  static const Color hex_FFFFF3E0 = Color(0xFFFFF3E0);
  static const Color hex_FFFFF5D6 = Color(0xFFF0FCFA);
}
