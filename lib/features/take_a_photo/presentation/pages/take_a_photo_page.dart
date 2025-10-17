import 'package:flutter/material.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
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

class TakeAPhotoPage extends StatelessWidget {
  const TakeAPhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      body: Center(
        child: Text(
          'Take a Photo',
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
        onTap: () {
          openSelectAPhotoPage(context); // Navigate to Select a Photo page
        },
      ),
      NavButton(
        icon: Icons.camera_alt,
        label: '',
        isSelected: true, // current page
        onTap: () {
          // Already on Take a Photo page, do nothing or maybe refresh
        },
      ),
      NavButton(
        icon: Icons.visibility,
        label: '',
        onTap: () {
          openARLiveView(context); // Navigate to AR Live View page
        },
      ),
      NavButton(
        icon: Icons.menu_book,
        label: '',
        onTap: () {
          openColorLibraryPage(context); // Navigate to Color Library page
        },
      ),
      NavButton(
        icon: Icons.home,
        label: '',
        onTap: () {
          Navigator.pop(context); // Go back to previous page
        },
      ),
    ],
  ),
),
);
}
}