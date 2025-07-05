import 'package:flutter/material.dart';
import 'package:truehue/shared/presentation/widgets/button.dart';
import 'package:truehue/features/home/presentation/pages/home.dart';

class TestResultPage extends StatelessWidget {
  const TestResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        title: const Text('The Farnsworth D-15\n Color Blind Test', style: TextStyle(color: Colors.white)),
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'DIAGNOSIS: Normal Result',
              style: TextStyle(
                color: Color(0xFFCEF5FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Errors: 0, Unused caps: 0',
              style: TextStyle(
                color: Color(0xFFCEF5FF),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Placeholder for result summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFCEF5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Result analysis goes here.\n(e.g. Normal vision, mild deutan, etc.)',
                style: TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            CustomButton(
              title: 'Go to Home',
              fontSize: 20,
              width: 200,
              height: 60,
              softWrap: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
            ),

          ],
      )
      ),
    );
  }
}