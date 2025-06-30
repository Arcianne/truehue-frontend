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

            const Text(
              'Welcome\nto\nTrueHue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFCEF5FF), 
                fontSize: 35,
                // height: 1.5,
                ),
            ),

            const SizedBox (height: 30),
            
            const Text(
              'Do you already know\n your type of\ncolorblindness?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFCEF5FF),
                fontSize: 19,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox (height: 40),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCEF5FF),
                foregroundColor: Color(0xFF130E64),
                fixedSize: const Size(85, 31),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ColorBlindnessTypeSelector()),
                );
              },
              child: const Text(
                'Yes',
                style: TextStyle(fontSize: 19),
              ),
            ),

            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCEF5FF),
                foregroundColor: Color(0xFF130E64),
                fixedSize: const Size(85, 31),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FarnsworthTest()),
                );
              },
              child: const Text(
                'No',
                style: TextStyle(fontSize: 19),
              ),
            ),
        ],
      ),
    ));
  }
}
