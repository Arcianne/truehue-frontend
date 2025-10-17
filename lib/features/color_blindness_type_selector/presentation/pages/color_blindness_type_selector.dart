import 'package:flutter/material.dart';
import 'package:truehue/features/home/presentation/pages/home.dart';
import 'package:truehue/config/theme/custom_theme/elevated_button_extensions.dart';

class ColorBlindnessTypeSelector extends StatelessWidget {
  const ColorBlindnessTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
              child: Image.asset(
                'assets/icon/truehue_logo.png',
                width: 150,
                height: 150,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Select your Type of\n Color Blindness:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFCEF5FF),
                fontSize: 22,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 40),

            // Using extension method for type selector buttons
            ElevatedButtonExtensions.typeSelectorButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              text: 'Deuteranopia',
            ),

            const SizedBox(height: 20),

            ElevatedButtonExtensions.typeSelectorButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              text: 'Protanopia',
            ),

            const SizedBox(height: 20),

            ElevatedButtonExtensions.typeSelectorButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              text: 'Tritanopia',
            ),
          ],
        ),
      ),
    );
  }
}
