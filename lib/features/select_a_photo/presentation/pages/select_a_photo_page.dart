import 'package:flutter/material.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';

// import 'package:permission_handler/permission_handler.dart';

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
            // Navigate to Select a photo
          },
        ),
        NavButton(
          icon: Icons.camera_alt,
          label: '',
          isSelected: false,
          onTap: () {
            // Navigate to Take a photo
          },
        ),
        NavButton(
          icon: Icons.visibility,
          label: '',
          isSelected: false,
          onTap: () {
            // Navigate to  the ar live view
          },
        ),
        NavButton(
          icon: Icons.menu_book,
          label: '',
          onTap: () {
            // Navigate to color library
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