import 'package:flutter/material.dart';

import 'package:truehue/features/color_blindness_type_selector/presentation/pages/color_blindness_type_selector.dart';

import 'package:truehue/features/farnsworth_test/presentation/pages/farnsworth_test.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF130E64),
      body: _buildBody(context)
      );
  }

  _buildBody(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Image.asset('assets/icon/truehue_logo.png', width: 100, height: 100),
          const SizedBox(height: 20),
          const Text(
            'Welcome to TrueHue',
            style: TextStyle(
              color: Color(0xFFCEF5FF),
              fontSize: 24,
              fontStyle: FontStyle.italic,
            ),
          ),

            const Text(
              'Do you already know your type of color blindness?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFCEF5FF), 
                fontSize: 24,
                ),
            ),

            const SizedBox (height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCEF5FF),
                foregroundColor: Color(0xFF130E64),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ColorBlindnessTypeSelector()),
                );
              },
              child: const Text('Yes'),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCEF5FF),
                foregroundColor: Color(0xFF130E64),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FarnsworthTest()),
                );
              },
              child: const Text('No'),
            ),
        ],
      ),
    );
  }
}
