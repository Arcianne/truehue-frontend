import 'package:flutter/material.dart';

// import 'package:truehue/shared/presentation/widgets/button.dart';

class TestScreenPage extends StatefulWidget {
  const TestScreenPage({super.key});

  @override
  State<TestScreenPage> createState() => _TestScreenPageState();
}

class _TestScreenPageState extends State<TestScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF130E64),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0, left: 20.0, right: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'The Farnsworth D-15\nColor Blind Test',
              style: const TextStyle(color: Color(0xFFCEF5FF), fontSize: 28),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            '1. Tap a color from the top row.\n'
            '2. Tap a spot in the bottom row to place it.\n'
            '3. To move a color back, tap a white spot.\n'
            '4. Arrange all colors in order.\n'
            '5. Tap "Show Result" when you\'re done!',
            style: TextStyle(color: Color(0xFFCEF5FF), fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget _buildColorDisk(Color color, {bool border = false, double elevation = 0}) {
  //   return Material(
  //     elevation: elevation,
  //     shape: const CircleBorder(),
  //     child: Container(
  //       width: 40,
  //       height: 40,
  //       decoration: BoxDecoration(
  //         color: color,
  //         shape: BoxShape.circle,
  //         border: border ? Border.all(color: Colors.white, width: 2) : null,
  //       ),
  //     ),
  //   );
  }
