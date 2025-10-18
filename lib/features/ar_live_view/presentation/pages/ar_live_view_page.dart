import 'dart:io';
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
  XFile? _frozenImage;

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

  Future<void> _onFreezePressed() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      setState(() {
        _frozenImage = image;
      });

      //TO-DO: This is where you would run your color-picking logic on the `_frozenImage` file.
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  void _onRetakePressed() {
    setState(() {
      _frozenImage = null;
    });
  }

  Future<void> _onSavePressed() async {
    if (_frozenImage == null) return;

    debugPrint('Image saved to: ${_frozenImage!.path}');
    // You could also save to the device gallery using the 'gallery_saver' package.

    setState(() {
      _frozenImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      body: Stack(
        fit: StackFit.expand,
        children: [
      FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_frozenImage == null) {
            return CameraPreview(_controller);
            } else {
              return Image.file(
                File (_frozenImage!.path),
                fit: BoxFit.cover,
                );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

  //layer 2 (color info card here):

      //-----Later 3: Custom Buttons-----
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 90.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //"Freeze/Retake" button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(108, 192, 174, 255).withValues(),
                  foregroundColor: Colors.black,
                ),
                icon: Icon(_frozenImage == null ? Icons.pause_rounded : Icons.refresh_rounded),
                label: Text(_frozenImage == null ? 'Freeze' : 'Retake'),
                onPressed: _frozenImage == null
                  ? _onFreezePressed
                  : _onRetakePressed,
              ),
              //Save button
              if (_frozenImage != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(108, 192, 174, 255).withValues(),
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Save'),
                  onPressed: _onSavePressed,
                  ),
            ],
          ),
        ),
      ),
    ],
  ),


      bottomNavigationBar: Container(
        color: const Color.fromARGB(47, 3, 0, 52),
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