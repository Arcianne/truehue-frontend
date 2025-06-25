import 'package:flutter/material.dart';

class FarnsworthTest extends StatelessWidget {
  const FarnsworthTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xFF130E64), body: _buildBody());
  }

  _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icon/truehue_logo.png', width: 100, height: 100),
          const SizedBox(height: 20),
          const Text(
            'Welcome to TrueHue',
            style: TextStyle(color: Color(0xFFCEF5FF), fontSize: 24),
          ),
          const Text(
            'The Farnsworth D-15 Color Blind Test',
            style: TextStyle(color: Color(0xFFCEF5FF), fontSize: 24),
            textAlign: TextAlign.center,
          ),

          const Text(
            'Note: You have to drag the color disks and arrange the hue of the colors properly based on what you see.',
            style: TextStyle(color: Color(0xFFCEF5FF), fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
