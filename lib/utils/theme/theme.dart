import 'package:flutter/material.dart';
import 'package:oji_1/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:oji_1/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:oji_1/utils/theme/custom_themes/text_field_theme.dart';
import 'package:oji_1/utils/theme/custom_themes/text_theme.dart';

class OAppTheme {
  OAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: OTextTheme.lightTextTheme,
    elevatedButtonTheme: OElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: OOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: OTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: OTextTheme.darkTextTheme,
    elevatedButtonTheme: OElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: OOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: OTextFormFieldTheme.darkInputDecorationTheme,
  );

}