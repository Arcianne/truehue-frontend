import 'package:flutter/material.dart';

class ColorBlindnessTypeSelector extends StatelessWidget {
  const ColorBlindnessTypeSelector({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Text('Select your type of color blindness:'),
        ],
      ),
    );
  }
}