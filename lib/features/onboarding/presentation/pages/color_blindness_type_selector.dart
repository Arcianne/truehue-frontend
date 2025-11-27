import 'package:flutter/material.dart';
import 'package:truehue/features/home/presentation/pages/home.dart';
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

    // Save the color blindness type
    await prefs.setString('colorBlindnessType', type);

    // Auto-set mode to Assistive (since user is color blind)
    await prefs.setString('liveARMode', 'Assistive');

    // Mark onboarding as complete
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;

    // Navigate directly to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
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
