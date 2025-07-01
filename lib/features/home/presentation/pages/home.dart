import 'package:flutter/material.dart';

// import 'package:truehue/features/color_blindness_type_selector/presentation/pages/color_blindness_type_selector.dart';
import 'package:truehue/features/welcome/presentation/pages/welcome.dart';

import 'package:truehue/shared/presentation/widgets/button.dart';


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
        'Home Page',
      )
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

          const Text(
            'TrueHue',
            style: TextStyle(
              color: Color(0xFFCEF5FF),
              fontSize: 30,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'AR Live View',
            icon: Icons.visibility,
            iconSize: 24,
            softWrap: false,
            fontSize: 25,
            height: 60,
            width: 260,
            onPressed: () {
              Navigator.push(
                _buildBody(context),
                MaterialPageRoute(builder: (context) => Home()), //change to AR Live View page
              );
            },
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'Take Photo',
            icon: Icons.camera_alt,
            iconSize: 24,
            softWrap: false,
            fontSize: 25,
            height: 60,
            width: 260,
            onPressed: () {
              Navigator.push(
                _buildBody(context),
                MaterialPageRoute(builder: (context) => Home()), //change to Take Photo page
              );
            },
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'Select Photo',
            icon: Icons.photo_library,
            iconSize: 24,
            softWrap: false,
            fontSize: 25,
            height: 60,
            width: 260,
            onPressed: () {
              Navigator.push(
                _buildBody(context),
                MaterialPageRoute(builder: (context) => Home()), //change to Select Photo page
              );
            },
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'Color Library',
            icon: Icons.color_lens,
            iconSize: 24,
            softWrap: false,
            fontSize: 25,
            height: 60,
            width: 260,
            onPressed: () {
              Navigator.push(
                _buildBody(context),
                MaterialPageRoute(builder: (context) => Home()),//change to Color Library page
              );
            },
          ),


    //       const SizedBox(height: 50),
    //       ElevatedButton(
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Color(0xFFCEF5FF),
    //           foregroundColor: Color(0xFF130E64),
    //           // fixedSize: const Size(85, 31),
    //           shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(10),
    //         ),
    //         ),
    //         onPressed: () {},
    //         child: const Text('AR Live View',
    //         style: TextStyle(fontSize: 22),
    //         ),
    //       ),

    //       // const SizedBox(height: 20),
    //       ElevatedButton(
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Color(0xFFCEF5FF),
    //           foregroundColor: Color(0xFF130E64),
    //         ),
    //         onPressed: () {},
    //         child: const Text('Take Photo',
    //         style: TextStyle(fontSize: 22),
    //         ),
    //       ),

    //       ElevatedButton(
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Color(0xFFCEF5FF),
    //           foregroundColor: Color(0xFF130E64),
    //         ),
    //         onPressed: () {},
    //         child: const Text('Select Photo',
    //         style: TextStyle(fontSize: 22),
    //         ),
    //       ),

    //       ElevatedButton(
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Color(0xFFCEF5FF),
    //           foregroundColor: Color(0xFF130E64),
    //         ),
    //         onPressed: () {},
    //         child: const Text('Color Library',
    //         style: TextStyle(fontSize: 22),
    //         ),
    //       ),
    //     ],
    //   ),
    // ));
  // }
        ],
      ),
    ),
  );
}
}