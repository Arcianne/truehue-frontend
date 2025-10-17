import 'package:flutter/material.dart';
import 'package:truehue/config/theme/custom_theme/text_theme.dart';
import 'package:truehue/config/theme/custom_theme/elevated_button_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Bellota',
    brightness: Brightness.light,
    primaryColor: Color(0xFF130E64),
    scaffoldBackgroundColor: Color(0xFFCEF5FF),
    textTheme: TTextTheme.lightTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme
    );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Bellota',
    brightness: Brightness.dark,
    primaryColor: Color(0xFFCEF5FF),
    scaffoldBackgroundColor: Color(0xFF130E64),
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme
  );
}
