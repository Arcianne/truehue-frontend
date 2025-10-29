import 'package:flutter/material.dart';
import 'package:truehue/features/home/presentation/pages/home.dart';
import 'package:truehue/config/theme/custom_theme/elevated_button_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeSelectionPage extends StatefulWidget {
  const ModeSelectionPage({super.key});

  @override
  State<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage> {
  Future<void> completeOnboarding(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    await prefs.setString('liveARMode', mode);

    // ✅ Only use context if the widget is still mounted
    if (!mounted) return;

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
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(
                  top: 60.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Image.asset(
                  'assets/icon/truehue_logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'How do you want to\nuse Live AR?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFCEF5FF),
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButtonExtensions.typeSelectorButton(
                onPressed: () => completeOnboarding('Assistive'),
                text: 'Assistive',
              ),
              const SizedBox(height: 20),
              ElevatedButtonExtensions.typeSelectorButton(
                onPressed: () => completeOnboarding('Simulation'),
                text: 'Simulation',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
