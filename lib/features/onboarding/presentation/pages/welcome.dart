import 'package:flutter/material.dart';
import 'package:truehue/features/onboarding/presentation/pages/color_blindness_type_selector.dart';
import 'package:truehue/features/farnsworth_test/presentation/pages/farnsworth_test.dart';
import 'package:truehue/config/theme/custom_theme/elevated_button_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

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
            Text(
              'Welcome\nto\nTrueHue',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            Text(
              'Do you already know\n your type of\ncolorblindness?',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),

            // Yes Button → knows type
            ElevatedButtonExtensions.yesNoButton(
              onPressed: () async {
                // Save that onboarding was seen
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('hasSeenOnboarding', true);

                // Navigate to ColorBlindnessTypePage
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ColorBlindnessTypePage(),
                  ),
                );
              },
              text: "Yes",
            ),
            const SizedBox(height: 15),

            // No Button → take Farnsworth Test
            ElevatedButtonExtensions.yesNoButton(
              onPressed: () async {
                // Save that onboarding was seen
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('hasSeenOnboarding', true);

                // Navigate to Farnsworth Test
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FarnsworthTest()),
                );
              },
              text: "No",
            ),
          ],
        ),
      ),
    );
  }
}
