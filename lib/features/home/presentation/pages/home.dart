import 'package:flutter/material.dart';

import 'package:truehue/features/color_blindness_type_selector/presentation/pages/color_blindness_type_selector.dart';

class Home extends StatelessWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(context),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ColorBlindnessTypeSelector(),
            ),
          );
        },
        child: const Text('Color Blindness Type Page'),
      ),
    );
  }

  _buildAppbar() {
    return AppBar(
      title: const Text(
        'home page',
      )
    );
  }

  _buildBody(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text('this is ColorBlindnessTypeSelector page put the content here'),
        ],
      ),
    );
  }
}