import 'package:flutter/material.dart';

class TestResultPage extends StatelessWidget {
  const TestResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Farnsworth D-15\nColor Blind Test'),
      ),
      body: const Center(
        child: Text('DIAGNOSIS: Normal Vision\n Errors: 0, Unused caps: 0', // Displaying the result of the test, change niyo nalang if gagawa kayo key
            style: TextStyle(fontSize: 24, color: Color(0xFFCEF5FF))),
      ),
    );
  }
}

// Use this function to navigate to the TestResultPage
void navigateToTestResultPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const TestResultPage()),
  );
}