// elevated_button_extensions.dart
import 'package:flutter/material.dart';

extension ElevatedButtonExtensions on ElevatedButton {
  // For Yes/No buttons (same size)
  static ElevatedButton yesNoButton({
    required VoidCallback? onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(85, 31),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Bellota',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // For color blindness type buttons (medium size for longer text)
  static ElevatedButton typeSelectorButton({
    required VoidCallback? onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(180, 45), // Wider for longer text
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Bellota',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // For homepage button
  static ElevatedButton homePageButton({
    required VoidCallback? onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Bellota',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
