import 'package:flutter/material.dart';

class OChipTheme {
  OChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: Colors.grey.withOpacity(0.4),
    labelStyle: const TextStyle(
      color: Colors.black
    ),
    selectedColor: Colors.blue,
    padding: const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 12
    ),
    checkmarkColor: Colors.white,
  );

  static ChipThemeData darktChipTheme = ChipThemeData(
    disabledColor: Colors.grey.withOpacity(0.4),
    labelStyle: const TextStyle(
        color: Colors.white
    ),
    selectedColor: Colors.blue,
    padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 12
    ),
    checkmarkColor: Colors.white,
  );
}