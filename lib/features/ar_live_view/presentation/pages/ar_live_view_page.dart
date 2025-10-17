import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:truehue/main.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';

void openARLiveView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ArLiveViewPage(camera: firstCamera),
    ),
  );
}

void openTakeAPhotoPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TakeAPhotoPage(camera: firstCamera),
    ),
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

class ArLiveViewPage extends StatefulWidget {
  final CameraDescription camera;

  const ArLiveViewPage({super.key, required this.camera});

  @override
  State<ArLiveViewPage> createState() => _ARLiveViewPageState();
}

class _ARLiveViewPageState extends State<ArLiveViewPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      body: FutureBuilder<void> (
        future: _initializeControllerFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
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
                openSelectAPhotoPage(context); // Navigate to Select a photo
              },
            ),
            NavButton(
              icon: Icons.camera_alt,
              label: '',
              onTap: () {
                openTakeAPhotoPage(context); // Navigate to Take a photo
              },
            ),
            NavButton(
              icon: Icons.visibility,
              label: '',
              isSelected: true,
              onTap: () {
                // Already on this page, the ar live view
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



// class ARLiveViewPage extends StatelessWidget {
//   const ARLiveViewPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF130E64),
//       body: Center(
//         child: Text(
//           'AR Live View',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

      