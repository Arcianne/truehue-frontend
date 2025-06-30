import 'package:flutter/material.dart';

// import 'package:truehue/features/color_blindness_type_selector/presentation/pages/color_blindness_type_selector.dart';

import 'package:truehue/features/home/presentation/pages/home.dart';

class ColorBlindnessTypeSelector extends StatelessWidget {
  const ColorBlindnessTypeSelector({ super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF130E64),
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  _buildAppbar() {
    return AppBar(
      title: const Text(
        'ColorBlindnessTypeSelector',
      ),
    );
  }

  _buildBody() {
    return Center(
      child: Column(
        children: <Widget>[
          Image.asset('assets/icon/truehue_logo.png', width: 100, height: 100),

          const SizedBox(height: 20),
          const Text(
            'Select your Type of Color Blindness:',
            style: TextStyle(
              color: Color(0xFFCEF5FF),
              fontSize: 24,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCEF5FF),
              foregroundColor: Color(0xFF130E64),
            ),
            onPressed: () {
              Navigator.push(
                _buildBody(),
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            child: const Text('Protanopia'),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCEF5FF),
              foregroundColor: Color(0xFF130E64),
            ),
            onPressed: () {
              Navigator.push(
                _buildBody(),
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            child: const Text('Deuteranopia'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCEF5FF),
              foregroundColor: Color(0xFF130E64),
            ),
            onPressed: () {
              Navigator.push(
                _buildBody(),
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            child: const Text('Tritanopia'),
          ),
        ],
      ),
    );
  }
}