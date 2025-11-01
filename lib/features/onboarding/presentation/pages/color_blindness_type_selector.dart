import 'package:flutter/material.dart';
import 'mode_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truehue/config/theme/custom_theme/elevated_button_extensions.dart';

class ColorBlindnessTypePage extends StatefulWidget {
  const ColorBlindnessTypePage({super.key});

  @override
  State<ColorBlindnessTypePage> createState() => _ColorBlindnessTypePageState();
}

class _ColorBlindnessTypePageState extends State<ColorBlindnessTypePage> {
  String selectedType = '';

  Future<void> saveTypeAndNext(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorBlindnessType', type);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ModeSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Choose your type of color blindness:",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Using custom ElevatedButtonExtensions
              ElevatedButtonExtensions.typeSelectorButton(
                onPressed: () => saveTypeAndNext('Protanopia'),
                text: 'Protanopia',
              ),
              const SizedBox(height: 15),
              ElevatedButtonExtensions.typeSelectorButton(
                onPressed: () => saveTypeAndNext('Deuteranopia'),
                text: 'Deuteranopia',
              ),
              const SizedBox(height: 15),
              ElevatedButtonExtensions.typeSelectorButton(
                onPressed: () => saveTypeAndNext('Tritanopia'),
                text: 'Tritanopia',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
