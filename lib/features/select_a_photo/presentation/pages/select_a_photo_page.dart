import 'package:flutter/material.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';

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

class SelectAPhotoPage extends StatelessWidget {
  const SelectAPhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      body: Center(
        child: Text(
          'Select a Photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBar: Container(
        color: const Color(0xFF130E64),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavButton(
              icon: Icons.upload_outlined,
              label: '',
              isSelected: true,
              onTap: () {
                openSelectAPhotoPage(context); // Navigate to Select a photo
              },
            ),
            NavButton(
              icon: Icons.camera_alt,
              label: '',
              isSelected: false,
              onTap: () {
                openTakeAPhotoPage(context); // Navigate to Take a photo
              },
            ),
            NavButton(
              icon: Icons.visibility,
              label: '',
              isSelected: false,
              onTap: () {
                openARLiveView(context); // Navigate to  the ar live view
              },
            ),
            NavButton(
              icon: Icons.menu_book,
              label: '',
              onTap: () {
                openColorLibraryPage(context); // Navigate to color library
              },
            ),
            NavButton(
              icon: Icons.home,
              label: '',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
