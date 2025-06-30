import 'package:flutter/material.dart';

// import 'package:truehue/features/color_blindness_type_selector/presentation/pages/color_blindness_type_selector.dart';
import 'package:truehue/features/welcome/presentation/pages/welcome.dart';

class Home extends StatelessWidget {
  const Home({ super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF130E64),
      appBar: _buildAppbar(),
      body: _buildBody(context),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Welcome(),
            ),
          );
        },
        child: const Text('Welcome Page'),
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
          Image.asset('assets/icon/truehue_logo.png', width: 100, height: 100),
          const SizedBox(height: 20),
          const Text(
            'TrueHue',
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
            onPressed: () {},
            child: const Text('AR Live View'),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCEF5FF),
              foregroundColor: Color(0xFF130E64),
            ),
            onPressed: () {},
            child: const Text('Take Photo'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCEF5FF),
              foregroundColor: Color(0xFF130E64),
            ),
            onPressed: () {},
            child: const Text('Select Photo'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCEF5FF),
              foregroundColor: Color(0xFF130E64),
            ),
            onPressed: () {},
            child: const Text('Color Library'),
          ),
        ],
      ),
    );
  }
}