import 'package:flutter/material.dart';

// import 'package:truehue/features/color_blindness_type_selector/presentation/pages/color_blindness_type_selector.dart';

import 'package:truehue/features/home/presentation/pages/home.dart';

import 'package:truehue/shared/presentation/widgets/button.dart';

class ColorBlindnessTypeSelector extends StatelessWidget {
  const ColorBlindnessTypeSelector({ super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF130E64),
      appBar: _buildAppbar(),
      body: _buildBody(context),
    );
  }

  _buildAppbar() {
    return AppBar(
      title: const Text(
        'ColorBlindnessTypeSelector',
      ),
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

          const SizedBox(height: 20),
          const Text(
            'Select your Type of\n Color Blindness:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFCEF5FF),
              fontSize: 22,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 40),

          CustomButton(
            title: 'Deuteranopia',
            softWrap: false,
            fontSize: 19,
            onPressed: () {
              Navigator.push(
                _buildBody(context),
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            height: 50,
            width: 180,
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'Protanopia',
            softWrap: false,
            fontSize: 19,
            onPressed: () {
              Navigator.push(
                _buildBody(context),
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            height: 50,
            width: 180,
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'Tritanopia',
            softWrap: false,
            fontSize: 19,
            onPressed: () {
              Navigator.push(
                _buildBody(context),
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            height: 50,
            width: 180,
          ),
        ],
      ),
    ));
  }
}