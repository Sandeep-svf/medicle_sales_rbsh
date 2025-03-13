import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import 'custom_theme/checkbox_theme.dart';
import 'custom_theme/elevated_button_theme.dart';
import 'custom_theme/outlined_button_theme.dart';
import 'custom_theme/text_field_theme.dart';
import 'custom_theme/text_theme.dart';


class SAppTheme{
  // using this so constructor is not going to use again and again...
  // using underscore make it private
  SAppTheme._();


  /// LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,  // for better performance using material design 3
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: Colors.white,
    textTheme: STextTheme.lightTextTheme,
    elevatedButtonTheme: SElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: SOutlinedButtonTheme.lightOutlinedButtonTheme,
    checkboxTheme: SCheckboxTheme.lightCheckboxTheme,
    inputDecorationTheme: STextFormFieldTheme.lightInputDecorationTheme,
  );

  /// DARK THEME
  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,  // for better performance using material design 3
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      primaryColor:  TColors.primary,
      scaffoldBackgroundColor: Colors.black,
      textTheme: STextTheme.darkTextTheme,
      elevatedButtonTheme: SElevatedButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: SOutlinedButtonTheme.darkOutlinedButtonTheme,
      checkboxTheme: SCheckboxTheme.darkCheckboxTheme,
      inputDecorationTheme: STextFormFieldTheme.darkInputDecorationTheme,
  );

}
