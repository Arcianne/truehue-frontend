import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';

import 'package:truehue/features/filters/presentation/pages/filter_page.dart';
import 'package:truehue/core/algorithm/knn_color_matcher.dart';
import 'package:truehue/main.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';

void openARLiveView(
  BuildContext context,
  bool assistiveMode, {
  String? simulationType,
}) {
  Navigator.push(
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
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TakeAPhotoPage(camera: firstCamera),
    ),
  );
}

void openColorLibraryPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ColorLibraryPage()),
  );
}

class SelectAPhotoPage extends StatefulWidget {
  const SelectAPhotoPage({super.key});

  @override
  State<SelectAPhotoPage> createState() => _SelectAPhotoPageState();
}

class _SelectAPhotoPageState extends State<SelectAPhotoPage> {
  XFile? _selectedImage;
  img.Image? _decodedImage;
  Offset? _tapPosition;
  Color _pickedColor = Colors.white;
  String _colorName = "";
  String _colorFamily = "";
  int _r = 0, _g = 0, _b = 0;
  final GlobalKey _imageKey = GlobalKey();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Automatically open gallery on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImage();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      setState(() {
        _selectedImage = picked;
        _decodedImage = img.decodeImage(bytes);
        _tapPosition = null;
        _pickedColor = Colors.white;
        _colorName = "";
        _colorFamily = "";
      });
    } else {
      // User cancelled: go back automatically
      Navigator.pop(context);
    }
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

  void _handleTap(TapDownDetails details) {
    if (_decodedImage == null) return;
    _tapPosition = details.localPosition;

    final renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final widgetSize = renderBox.size;

    final mapped = _mapTapToImage(
      widgetSize,
      _decodedImage!.width,
      _decodedImage!.height,
      _tapPosition!,
    );

    _pickedColor = _weightedAveragePixels(
      _decodedImage!,
      mapped.dx.round(),
      mapped.dy.round(),
    );

    _r = _pickedColor.red;
    _g = _pickedColor.green;
    _b = _pickedColor.blue;

    _colorName = ColorMatcher.getColorName(_r, _g, _b, k: 5);
    _colorFamily = ColorMatcher.getColorFamily(_r, _g, _b);

    setState(() {});
  }

  void _resetToGallery() {
    _pickImage();
  }

  Future<void> _openFilterPage() async {
    if (_selectedImage == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(
          imagePath: _selectedImage!.path,
          sourcePageTitle: "Select A Photo",
        ),
      ),
    );

    if (result != null && result is String) {
      final bytes = await File(result).readAsBytes();
      setState(() {
        _selectedImage = XFile(result);
        _decodedImage = img.decodeImage(bytes);
        _tapPosition = null;
        _colorName = "";
      });
    }
  }

  Future<void> _saveImage() async {
    if (_selectedImage == null) return;

    setState(() => _isSaving = true);

    try {
      await Gal.requestAccess();
      await Gal.putImage(_selectedImage!.path, album: 'TrueHue');

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTapDown: _handleTap,
            child: _selectedImage != null
                ? Image.file(
                    File(_selectedImage!.path),
                    key: _imageKey,
                    fit: BoxFit.contain,
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
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
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
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
                      'Select A Photo',
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

          // Color info card
          if (_selectedImage != null && _colorName.isNotEmpty)
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
                      color: Colors.black.withOpacity(0.3),
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
                            _colorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$_colorFamily Family",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "RGB: $_r, $_g, $_b",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Tap marker
          if (_tapPosition != null && _selectedImage != null)
            Positioned(
              left: _tapPosition!.dx - 15,
              top: _tapPosition!.dy - 15,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _pickedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),

          // Bottom buttons
          if (_selectedImage != null)
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
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton.icon(
                          onPressed: _resetToGallery,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text(
                            'RESELECT',
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
              isSelected: true,
              onTap: () {},
            ),
            NavButton(
              icon: Icons.camera_alt,
              label: '',
              onTap: () => openTakeAPhotoPage(context),
            ),
            NavButton(
              icon: Icons.visibility,
              label: '',
              onTap: () => Navigator.pop(context),
            ),
            NavButton(
              icon: Icons.menu_book,
              label: '',
              onTap: () => openColorLibraryPage(context),
            ),
            NavButton(
              icon: Icons.home,
              label: '',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
