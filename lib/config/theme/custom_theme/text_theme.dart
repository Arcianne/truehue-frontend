import 'package:flutter/material.dart';

class TTextTheme {
  TTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    titleLarge: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 35,
      fontStyle: FontStyle.italic,
      color: Color(0xFF130E64),
    ),
    titleMedium: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 30,
      color: Color(0xFF130E64)),

    bodyLarge: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 22,
      fontStyle: FontStyle.italic,
      color: Color(0xFF130E64),
    ),
    bodyMedium: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 14,
      color: Color(0xFF130E64)
    ),

    labelLarge: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 25, 
      color: Color(0xFF130E64))
  );

  static TextTheme darkTextTheme = TextTheme(
    titleLarge: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 35,
      fontStyle: FontStyle.italic,
      color: Color(0xFFCEF5FF),
      ),
    titleMedium: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 30,
      color: Color(0xFFCEF5FF),
    ),

    bodyLarge: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 22,
      fontStyle: FontStyle.italic,
      color: Color(0xFFCEF5FF),
    ),
    bodyMedium: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 14,
      color: Color(0xFFCEF5FF)
    ),

    labelLarge: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 25,
      color: Color(0xFFCEF5FF)
    ),
    labelMedium: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 19,
      color: Color(0xFFCEF5FF)
    ),
    labelSmall: TextStyle().copyWith(
      fontFamily: 'Bellota',
      fontSize: 14,
      color: Color(0xFFCEF5FF)
    )

  );
}
