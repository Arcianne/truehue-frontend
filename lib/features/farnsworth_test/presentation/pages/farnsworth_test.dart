import 'package:flutter/material.dart';
import 'package:truehue/features/farnsworth_test/presentation/pages/test_screen_page.dart';

class FarnsworthTest extends StatelessWidget {
  const FarnsworthTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        // Added to make content scrollable
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ), // Added horizontal padding
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10.0), // Reduced top margin
                Image.asset(
                  'assets/icon/truehue_logo.png',
                  width: 120, // Reduced size
                  height: 120,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Welcome\nto\nTrueHue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFCEF5FF),
                    fontSize: 24,
                  ), // Reduced font size
                ),

                const SizedBox(height: 15),

                const Text(
                  'The Farnsworth D-15\nColor Blind Test',
                  style: TextStyle(
                    color: Color(0xFFCEF5FF),
                    fontSize: 20, // Reduced font size
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Note: You have to drag the color disks and arrange the hue of the colors properly based on what you see.',
                    style: TextStyle(
                      color: Color(0xFFCEF5FF),
                      fontSize: 13,
                    ), // Reduced font size
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30), // Reduced spacing

                Container(
                  width: double.infinity, // Use available width
                  constraints: const BoxConstraints(
                    maxWidth: 320,
                  ), // But limit maximum width
                  padding: const EdgeInsets.all(15), // Reduced padding
                  decoration: BoxDecoration(
                    color: const Color(0xFFCEF5FF),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF67D4F1),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Take only needed space
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 2,
                        runSpacing: 2,
                        children: [
                          _buildColorDisk(const Color(0xFF67D4F1)),
                          _buildColorDisk(const Color(0xFF65D0E2)),
                          _buildColorDisk(const Color(0xFF67D3D6)),
                          _buildColorDisk(const Color(0xFF75D5C9)),
                          _buildColorDisk(const Color(0xFF6ED0B9)),
                          _buildColorDisk(const Color(0xFF8AC78E)),
                          _buildColorDisk(const Color(0xFFA3BD4F)),
                          _buildColorDisk(const Color(0xFFD0B244)),
                          _buildColorDisk(const Color(0xFFDDA149)),
                          _buildColorDisk(const Color(0xFFE99569)),
                          _buildColorDisk(const Color(0xFFE89784)),
                          _buildColorDisk(const Color(0xFFE999A3)),
                          _buildColorDisk(const Color(0xFFD59FB4)),
                          _buildColorDisk(const Color(0xFFD099C3)),
                          _buildColorDisk(const Color(0xFFC8A7DB)),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 2,
                        runSpacing: 2,
                        children: List.generate(
                          15,
                          (index) => Container(
                            width: 16, // Slightly smaller
                            height: 16,
                            decoration: BoxDecoration(
                              color: index == 1
                                  ? const Color(0xFF67D4F1)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30), // Reduced spacing

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TestScreenPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50), // Slightly smaller button
                  ),
                  child: const Text('Take the Test'),
                ),

                const SizedBox(height: 20), // Added bottom padding for safety
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorDisk(Color color) {
    return Container(
      width: 16, // Slightly smaller
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
