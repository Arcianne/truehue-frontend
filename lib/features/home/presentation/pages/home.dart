import 'package:flutter/material.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';
import 'package:truehue/features/welcome/presentation/pages/welcome.dart';

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
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(context),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Welcome()),
          );
        },
        child: const Text('Welcome Page'),
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(title: const Text('Home Page'));
  }

  Widget _buildBody(BuildContext context) {
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
              style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.visibility, size: 24),
              label: const Text('AR Live View', style: TextStyle(fontSize: 25)),
              style: ElevatedButton.styleFrom(minimumSize: const Size(260, 60)),
              onPressed: () => openARLiveView(context),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt, size: 24),
              label: const Text('Take a Photo', style: TextStyle(fontSize: 25)),
              style: ElevatedButton.styleFrom(minimumSize: const Size(260, 60)),
              onPressed: () => openTakeAPhotoPage(context),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.upload_outlined, size: 24),
              label: const Text(
                'Select a Photo',
                style: TextStyle(fontSize: 25),
              ),
              style: ElevatedButton.styleFrom(minimumSize: const Size(260, 60)),
              onPressed: () => openSelectAPhotoPage(context),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.menu_book, size: 24),
              label: const Text(
                'Color Library',
                style: TextStyle(fontSize: 25),
              ),
              style: ElevatedButton.styleFrom(minimumSize: const Size(260, 60)),
              onPressed: () => openColorLibraryPage(context),
            ),
          ],
        ),
      ),
    );
  }
}
