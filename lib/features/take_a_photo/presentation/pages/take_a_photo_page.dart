import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:truehue/main.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
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

class TakeAPhotoPage extends StatefulWidget {
  final CameraDescription camera;

  const TakeAPhotoPage({super.key, required this.camera});

  @override
  State<TakeAPhotoPage> createState() => _TakeAPhotoPageState();
}

class _TakeAPhotoPageState extends State<TakeAPhotoPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.high);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt_rounded),
        onPressed: () async {

          final currentContext = context;

          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if (!mounted || !currentContext.mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    DisplayPictureScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            debugPrint('Error taking picture: $e');
          }
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

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
                openSelectAPhotoPage(
                  context,
                ); // Navigate to Select a Photo page
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

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
