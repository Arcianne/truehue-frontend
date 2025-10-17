import 'package:flutter/material.dart';

class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  // Light Theme - Only define colors, let buttons handle sizes
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: const Color(0xFFCEF5FF),
      backgroundColor: const Color(0xFF130E64),
      textStyle: const TextStyle(
        fontFamily: 'Bellota',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  // Dark Theme - Only define colors, let buttons handle sizes
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: const Color(0xFF130E64),
      backgroundColor: const Color(0xFFCEF5FF),
      textStyle: const TextStyle(
        fontFamily: 'Bellota',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
