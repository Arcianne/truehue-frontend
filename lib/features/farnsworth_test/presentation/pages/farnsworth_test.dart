import 'package:flutter/material.dart';

import 'package:truehue/shared/presentation/widgets/button.dart';

import 'package:truehue/features/farnsworth_test/presentation/pages/test_screen_page.dart';


class FarnsworthTest extends StatelessWidget {
  const FarnsworthTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xFF130E64), body: _buildBody(context));
  }

 _buildBody(BuildContext context) {
  return SafeArea(
    child: Center(
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: Image.asset(
              'assets/icon/truehue_logo.png',
              width: 150,
              height: 150,
            ),
          ),

          const Text(
            'Welcome\nto\nTrueHue',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFCEF5FF), fontSize: 28),
          ),

          const SizedBox(height: 20),

          const Text(
            'The Farnsworth D-15\nColor Blind Test',
            style: TextStyle(color: Color(0xFFCEF5FF), fontSize: 22),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          const Text(
            'Note: You have to drag the color disks and arrange the hue of the colors properly based on what you see.',
            style: TextStyle(color: Color(0xFFCEF5FF), fontSize: 14),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 50),

          Container(
            width: 320,
            height: 180,
            decoration: BoxDecoration(
              color: Color(0xFFCEF5FF), // Light blue background
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Color(0xFF67D4F1), width: 2), // Blue border
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

          Wrap(
            alignment: WrapAlignment.start,
            spacing: 2,
            runSpacing: 2,
            children: [
              _buildColorDisk(Color(0xFF67D4F1)),
              _buildColorDisk(Color(0xFF65D0E2)),
              _buildColorDisk(Color(0xFF67D3D6)),
              _buildColorDisk(Color(0xFF75D5C9)),
              _buildColorDisk(Color(0xFF6ED0B9)),
              _buildColorDisk(Color(0xFF8AC78E)),
              _buildColorDisk(Color(0xFFA3BD4F)),
              _buildColorDisk(Color(0xFFD0B244)),
              _buildColorDisk(Color(0xFFDDA149)),
              _buildColorDisk(Color(0xFFE99569)),
              _buildColorDisk(Color(0xFFE89784)),
              _buildColorDisk(Color(0xFFE999A3)),
              _buildColorDisk(Color(0xFFD59FB4)),
              _buildColorDisk(Color(0xFFD099C3)),
              _buildColorDisk(Color(0xFFC8A7DB)),
            ],
          ),

          const SizedBox(height: 20),

            Wrap(
              alignment: WrapAlignment.start,
              spacing: 2,
              runSpacing: 2,
              children: List.generate(
              15,
              (index) => Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                color: index == 0 ? Color(0xFF67D4F1) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 1),
                ),
              ),
              ),
            ),

          const SizedBox(height: 40),

          CustomButton(
            title: 'Take the Test',
            fontSize: 25,
            width: 200,
            height: 60,
            softWrap: true,
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestScreenPage()),
                );
              },
          )
        ],
      ),
    )
  
        ]
    ),
  )
  );
  }

        Widget _buildColorDisk(Color color) {
          return Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          );
        }
      }
