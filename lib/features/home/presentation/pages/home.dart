import 'package:flutter/material.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';

// import 'package:permission_handler/permission_handler.dart';

// import 'package:truehue/features/color_blindness_type_selector/presentation/pages/color_blindness_type_selector.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';
import 'package:truehue/features/welcome/presentation/pages/welcome.dart';

import 'package:truehue/shared/presentation/widgets/button.dart';

void openARLiveView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ARLiveViewPage()),
  );
}

void openTakeAPhotoPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const TakeAPhotoPage()),
  );
}

void openSelectAPhotoPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SelectAPhotoPage()),
  );
}

void openColorLibraryPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ColorLibraryPage()),
  );
}


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
              openARLiveView(context); //nakuha ko rin, bwisit
            },
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'Take a Photo',
            icon: Icons.camera_alt,
            iconSize: 24,
            softWrap: false,
            fontSize: 25,
            height: 60,
            width: 260,
            onPressed: () {
              openTakeAPhotoPage(context); //nakuha ko rin, bwisit
            },
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'Select a Photo',
            icon: Icons.upload_outlined,
            iconSize: 24,
            softWrap: false,
            fontSize: 25,
            height: 60,
            width: 260,
            onPressed: () {
              openSelectAPhotoPage(context); //nakuha ko rin, bwisit
            },
          ),

          const SizedBox(height: 20),

          CustomButton(
            title: 'Color Library',
            icon: Icons.menu_book,
            iconSize: 24,
            softWrap: false,
            fontSize: 25,
            height: 60,
            width: 260,
            onPressed: () {
              openColorLibraryPage(context); //nakuha ko rin, bwisit
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