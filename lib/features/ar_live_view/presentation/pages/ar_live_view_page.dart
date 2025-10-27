import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tts/flutter_tts.dart';

import 'package:truehue/core/algorithm/knn_color_matcher.dart';
import 'package:truehue/main.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
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
  final bool assistiveMode;
  final String? simulationType;

  const ArLiveViewPage({
    super.key,
    required this.assistiveMode,
    this.simulationType,
  });

  @override
  State<ArLiveViewPage> createState() => _ArLiveViewState();
}

class _ArLiveViewState extends State<ArLiveViewPage> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  final FlutterTts _tts = FlutterTts();
  bool _isProcessing = false;
  bool _isScanning = false;
  bool _ttsReady = false;
  Color _sampledColor = Colors.transparent;
  String _colorName = "";
  String _colorFamily = "";
  int _r = 0, _g = 0, _b = 0;
  // DateTime? _lastSpeechTime;
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeCamera();
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showInstructions = false);
    });
  }

  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        debugPrint("✅ Speech completed");
      });

      _tts.setErrorHandler((msg) {
        debugPrint("❌ TTS Error: $msg");
      });

      setState(() => _ttsReady = true);
      debugPrint("✅ TTS initialized successfully");
    } catch (e) {
      debugPrint("❌ TTS initialization error: $e");
      setState(() => _ttsReady = false);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    } catch (e) {
      debugPrint("❌ Camera initialization error: $e");
    }
  }

  void _toggleScanning() async {
    if (_isScanning) {
      await _controller?.stopImageStream();
      setState(() {
        _isScanning = false;
        _colorName = "";
        _colorFamily = "";
        _sampledColor = Colors.transparent;
      });
    } else {
      if (_controller != null && !_controller!.value.isStreamingImages) {
        setState(() => _isScanning = true);
        await _controller!.startImageStream(_processCameraImage);
      }
    }
  }

  Future<void> _speakColor() async {
    if (!widget.assistiveMode || !_ttsReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text-to-speech not available'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    await _tts.stop();
    await _tts.speak(_colorName);
    debugPrint("🔊 Speaking: $_colorName");
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final rgb = _convertYUV420ToImage(image);
      if (rgb == null) return;

      final sampleX = rgb.width ~/ 2;
      final sampleY = rgb.height ~/ 2;

      final pixel = rgb.getPixel(sampleX, sampleY);

      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      final detectedColor = Color.fromARGB(255, r, g, b);

      // Use ColorMatcher KNN algorithm (k=5 for best accuracy)
      final name = ColorMatcher.getColorName(r, g, b, k: 5);
      final family = ColorMatcher.getColorFamily(r, g, b);

      debugPrint("🎨 Detected: $name ($family) - RGB($r, $g, $b)");

      setState(() {
        _sampledColor = detectedColor;
        _colorName = name;
        _colorFamily = family;
        _r = r;
        _g = g;
        _b = b;
      });
    } catch (e) {
      debugPrint('❌ Error processing frame: $e');
    } finally {
      _isProcessing = false;
    }
  }

  img.Image? _convertYUV420ToImage(CameraImage image) {
    try {
      final width = image.width;
      final height = image.height;

      final imgData = img.Image(width: width, height: height);

      final uvRowStride = image.planes[1].bytesPerRow;
      final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;
      final uBuffer = image.planes[1].bytes;
      final vBuffer = image.planes[2].bytes;
      final yBuffer = image.planes[0].bytes;

      int yp = 0;
      for (int y = 0; y < height; y++) {
        final uvRow = (y / 2).floor();
        for (int x = 0; x < width; x++) {
          final uvCol = (x / 2).floor();
          final uvIndex = uvRow * uvRowStride + uvCol * uvPixelStride;

          final Y = yBuffer[yp];
          final U = uBuffer[uvIndex];
          final V = vBuffer[uvIndex];

          int r = (Y + 1.402 * (V - 128)).round();
          int g = (Y - 0.344136 * (U - 128) - 0.714136 * (V - 128)).round();
          int b = (Y + 1.772 * (U - 128)).round();

          r = r.clamp(0, 255);
          g = g.clamp(0, 255);
          b = b.clamp(0, 255);

          imgData.setPixelRgb(x, y, r, g, b);
          yp++;
        }
      }
      return imgData;
    } catch (e) {
      debugPrint('❌ YUV→RGB convert error: $e');
      return null;
    }
  }

  String _getModeName() {
    if (widget.assistiveMode) {
      return "Assistive Mode";
    } else {
      switch (widget.simulationType) {
        case 'deuteranopia':
          return "Deuteranopia Simulation";
        case 'tritanopia':
          return "Tritanopia Simulation";
        case 'protanopia':
        default:
          return "Protanopia Simulation";
      }
    }
  }

  Color _getFamilyColor(String family) {
    switch (family.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.amber;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'gray':
        return Colors.grey;
      case 'white':
        return Colors.black54;
      case 'black':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  ColorFilter _getColorFilter(String type) {
    switch (type) {
      case 'deuteranopia':
        return const ColorFilter.matrix([
          0.625,
          0.375,
          0,
          0,
          0,
          0.7,
          0.3,
          0,
          0,
          0,
          0,
          0.3,
          0.7,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'tritanopia':
        return const ColorFilter.matrix([
          0.95,
          0.05,
          0,
          0,
          0,
          0,
          0.433,
          0.567,
          0,
          0,
          0,
          0.475,
          0.525,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case 'protanopia':
      default:
        return const ColorFilter.matrix([
          0.567,
          0.433,
          0,
          0,
          0,
          0.558,
          0.442,
          0,
          0,
          0,
          0,
          0.242,
          0.758,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Camera preview
                Positioned.fill(
                  child: widget.assistiveMode
                      ? CameraPreview(_controller!)
                      : ColorFiltered(
                          colorFilter: _getColorFilter(
                            widget.simulationType ?? 'protanopia',
                          ),
                          child: CameraPreview(_controller!),
                        ),
                ),

                // Top bar with color count badge
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getModeName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Color database info badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${ColorMatcher.colorCount} colors",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Color card at TOP (when scanning)
                if (_isScanning && _colorName.isNotEmpty)
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
                          // Color circle
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _sampledColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Color info
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getFamilyColor(_colorFamily),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _colorFamily,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Family",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
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
                          // Audio button (tap to hear)
                          if (widget.assistiveMode)
                            IconButton(
                              onPressed: _speakColor,
                              icon: Icon(
                                _ttsReady ? Icons.volume_up : Icons.volume_off,
                                color: _ttsReady ? Colors.blue : Colors.grey,
                                size: 28,
                              ),
                              tooltip: "Tap to hear color",
                            ),
                        ],
                      ),
                    ),
                  ),

                // Instructions overlay
                if (_showInstructions)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => _showInstructions = false),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.8),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.assistiveMode
                                      ? Icons.camera_alt
                                      : Icons.visibility,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  widget.assistiveMode
                                      ? "How to Use Assistive Mode"
                                      : "How to Use Simulation Mode",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.assistiveMode
                                      ? "1. Tap START to begin\n2. Point the center circle at objects\n3. See color name appear at top\n4. Tap speaker icon to hear color\n\n✨ Using 750+ color database with KNN"
                                      : "1. This shows how ${widget.simulationType} affects vision\n2. Tap START to identify colors\n3. Move camera to explore\n\n✨ Using advanced color matching",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Tap anywhere to continue",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Center target circle
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isScanning ? Colors.green : Colors.white,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _isScanning ? Colors.green : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                      bottom: MediaQuery.of(context).padding.bottom + 16,
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
                    child: ElevatedButton.icon(
                      onPressed: _toggleScanning,
                      icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                      label: Text(
                        _isScanning ? "STOP SCANNING" : "START SCANNING",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isScanning
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // Bottom Navigation Bar
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
              onTap: () => openTakeAPhotoPage(context),
            ),
            NavButton(
              icon: Icons.visibility,
              label: '',
              isSelected: true,
              onTap: () {},
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

  @override
  void dispose() {
    _controller?.dispose();
    _tts.stop();
    super.dispose();
  }
}
