import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:truehue/main.dart';
import 'package:truehue/features/filters/presentation/pages/filter_page.dart';
import 'package:truehue/core/algorithm/knn_color_matcher.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';

Future<void> openARLiveView(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final mode = prefs.getString('liveARMode') ?? 'Assistive';
  final colorBlindType = prefs.getString('colorBlindnessType') ?? 'Normal';

  final bool assistiveMode = mode == 'Assistive';
  final String? simulationType = mode == 'Simulation'
      ? colorBlindType.toLowerCase()
      : null;

  if (!context.mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ArLiveViewPage(
        assistiveMode: assistiveMode,
        simulationType: simulationType,
      ),
    ),
  );
}

void openTakeAPhotoPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => TakeAPhotoPage(camera: firstCamera),
    ),
  );
}

class TakeAPhotoPage extends StatefulWidget {
  final CameraDescription camera;

  const TakeAPhotoPage({super.key, required this.camera});

  @override
  State<TakeAPhotoPage> createState() => _TakeAPhotoPageState();
}

void openSelectAPhotoPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const SelectAPhotoPage()),
  );
}

void openColorLibraryPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const ColorLibraryPage()),
  );
}

void openHomePage(BuildContext context) {
  Navigator.popUntil(context, (route) => route.isFirst);
}

class _TakeAPhotoPageState extends State<TakeAPhotoPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  XFile? _capturedImage;
  img.Image? _decodedImage;
  Offset? _tapPosition;
  Color _pickedColor = Colors.white;
  String _colorFamily = "";
  int _r = 0, _g = 0, _b = 0;
  final GlobalKey _imageKey = GlobalKey();
  bool _isSaving = false;

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

  Color _weightedAveragePixels(
    img.Image image,
    int x,
    int y, {
    int radius = 3,
  }) {
    int r = 0, g = 0, b = 0, totalWeight = 0;

    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        int distance = dx.abs() + dy.abs();
        int weight = (radius * 2 + 1) - distance;

        int px = (x + dx).clamp(0, image.width - 1);
        int py = (y + dy).clamp(0, image.height - 1);

        final pixel = image.getPixelSafe(px, py);
        r += pixel.r.toInt() * weight;
        g += pixel.g.toInt() * weight;
        b += pixel.b.toInt() * weight;
        totalWeight += weight;
      }
    }

    if (totalWeight == 0) return Colors.black;
    return Color.fromARGB(
      255,
      r ~/ totalWeight,
      g ~/ totalWeight,
      b ~/ totalWeight,
    );
  }

  Offset _mapTapToImage(
    Size widgetSize,
    int imageWidth,
    int imageHeight,
    Offset tap,
  ) {
    double scaleX = imageWidth / widgetSize.width;
    double scaleY = imageHeight / widgetSize.height;
    double x = (tap.dx * scaleX).clamp(0, imageWidth - 1).toDouble();
    double y = (tap.dy * scaleY).clamp(0, imageHeight - 1).toDouble();
    return Offset(x, y);
  }

  Future<void> _takePicture() async {
    await _initializeControllerFuture;
    final image = await _controller.takePicture();
    final bytes = await File(image.path).readAsBytes();

    setState(() {
      _capturedImage = image;
      _decodedImage = img.decodeImage(bytes);
      _tapPosition = null;
      _pickedColor = Colors.white;
      _colorFamily = "";
    });
  }

  void _resetToCamera() {
    setState(() {
      _capturedImage = null;
      _decodedImage = null;
      _tapPosition = null;
      _pickedColor = Colors.white;
      _colorFamily = "";
    });
  }

  Future<void> _openFilterPage() async {
    if (_capturedImage == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(
          imagePath: _capturedImage!.path,
          sourcePageTitle: "Take A Photo",
        ),
      ),
    );

    if (result != null && result is String) {
      final bytes = await File(result).readAsBytes();
      setState(() {
        _capturedImage = XFile(result);
        _decodedImage = img.decodeImage(bytes);
        _tapPosition = null;
      });
    }
  }

  void _updateColorAtPosition(Offset position) {
    if (_decodedImage == null) return;

    final renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final widgetSize = renderBox.size;

    final mapped = _mapTapToImage(
      widgetSize,
      _decodedImage!.width,
      _decodedImage!.height,
      position,
    );

    _pickedColor = _weightedAveragePixels(
      _decodedImage!,
      mapped.dx.round(),
      mapped.dy.round(),
    );

    _r = (_pickedColor.r * 255).round();
    _g = (_pickedColor.g * 255).round();
    _b = (_pickedColor.b * 255).round();

    _colorFamily = ColorMatcher.getColorFamily(_r, _g, _b);

    setState(() {
      _tapPosition = position;
    });
  }

  void _handlePanStart(DragStartDetails details) {
    if (_decodedImage == null) return;
    _updateColorAtPosition(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_decodedImage == null) return;
    _updateColorAtPosition(details.localPosition);
  }

  void _handleTap(TapDownDetails details) {
    if (_decodedImage == null) return;
    _updateColorAtPosition(details.localPosition);
  }

  Future<void> _saveImage() async {
    if (_capturedImage == null) return;

    setState(() => _isSaving = true);

    try {
      await Gal.requestAccess();
      await Gal.putImage(_capturedImage!.path, album: 'TrueHue');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTapDown: _handleTap,
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                child: _capturedImage == null
                    ? CameraPreview(_controller)
                    : Image.file(
                        File(_capturedImage!.path),
                        key: _imageKey,
                        fit: BoxFit.contain,
                      ),
              ),

              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Take A Photo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Color card
              if (_capturedImage != null && _colorFamily.isNotEmpty)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 70,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _pickedColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$_colorFamily ",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "RGB: $_r, $_g, $_b",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Tap marker with smooth animation
              if (_tapPosition != null && _capturedImage != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  left: _tapPosition!.dx - 15,
                  top: _tapPosition!.dy - 15,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _pickedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 90,
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: _capturedImage != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _openFilterPage,
                                  icon: const Icon(Icons.filter_alt, size: 18),
                                  label: const Text(
                                    'FILTER',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _resetToCamera,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text(
                                    'RETAKE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveImage,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Icon(Icons.download, size: 18),
                                  label: Text(
                                    _isSaving ? 'SAVING...' : 'SAVE',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: GestureDetector(
                            onTap: _takePicture,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),

      // Bottom nav bar
      bottomNavigationBar: Container(
        color: const Color.fromARGB(47, 3, 0, 52),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavButton(
              icon: Icons.upload_outlined,
              label: '',
              onTap: () => openSelectAPhotoPage(context),
            ),
            NavButton(
              icon: Icons.camera_alt,
              label: '',
              isSelected: true,
              onTap: () {},
            ),
            NavButton(
              icon: Icons.visibility,
              label: '',
              onTap: () => openARLiveView(context),
            ),
            NavButton(
              icon: Icons.menu_book,
              label: '',
              onTap: () => openColorLibraryPage(context),
            ),
            NavButton(
              icon: Icons.home,
              label: '',
              onTap: () => openHomePage(context),
            ),
          ],
        ),
      ),
    );
  }
}
