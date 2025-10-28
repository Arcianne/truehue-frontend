import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tts/flutter_tts.dart';
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

// ------------------- AR LIVE VIEW PAGE -------------------

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
  bool _showInstructions = true;

  Color _sampledColor = Colors.transparent;
  String _colorName = "";
  int _r = 0, _g = 0, _b = 0;
  String _previousColorName = "";
  bool _isSpeakingContinuously = false;
  Timer? _ttsTimer;

  // Improved color palette with better RGB values for accuracy
  final List<Map<String, Color>> simplifiedColors = [
    {'red': const Color(0xFFE53935)}, // Pure red
    {'orange': const Color(0xFFFF6F00)}, // Pure orange
    {'yellow': const Color(0xFFFDD835)}, // Bright yellow
    {'green': const Color(0xFF43A047)}, // True green
    {'blue': const Color(0xFF1E88E5)}, // Clear blue
    {'purple': const Color(0xFF8E24AA)}, // True purple
    {'pink': const Color(0xFFEC407A)}, // Bright pink
    {'brown': const Color(0xFF6D4C41)}, // Natural brown
    {'black': const Color(0xFF212121)}, // Near black
    {'white': const Color(0xFFFAFAFA)}, // Near white
    {'gray': const Color(0xFF9E9E9E)}, // Middle gray
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeCamera();
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showInstructions = false);
    });
  }

  // ---------------- TTS (FIXED) ----------------
  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        debugPrint("✅ TTS completed");
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

  void _toggleContinuousTTS() async {
    if (!_ttsReady || !widget.assistiveMode) {
      debugPrint("❌ TTS not ready or not in assistive mode");
      return;
    }

    if (_isSpeakingContinuously) {
      debugPrint("🔇 Stopping continuous TTS");
      _ttsTimer?.cancel();
      await _tts.stop();
      setState(() => _isSpeakingContinuously = false);
    } else {
      debugPrint("🔊 Starting continuous TTS");
      setState(() => _isSpeakingContinuously = true);
      _previousColorName = "";

      // Speak immediately if color is available
      if (_colorName.isNotEmpty) {
        await _speakColor(_colorName);
      }

      _ttsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        if (!_isSpeakingContinuously || !mounted) return;
        if (_colorName.isNotEmpty && _colorName != _previousColorName) {
          await _speakColor(_colorName);
        }
      });
    }
  }

  Future<void> _speakColor(String color) async {
    if (!_ttsReady) return;

    _previousColorName = color;
    debugPrint("🔊 Speaking: $color");

    try {
      await _tts.stop();
      await Future.delayed(const Duration(milliseconds: 50));
      await _tts.speak(color);
    } catch (e) {
      debugPrint("❌ Error speaking: $e");
    }
  }

  // ---------------- CAMERA ----------------
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
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
        _sampledColor = Colors.transparent;
      });

      // Stop continuous TTS when scanning stops
      if (_isSpeakingContinuously) {
        _ttsTimer?.cancel();
        await _tts.stop();
        setState(() => _isSpeakingContinuously = false);
      }
    } else {
      if (_controller != null && !_controller!.value.isStreamingImages) {
        setState(() => _isScanning = true);
        await _controller!.startImageStream(_processCameraImage);
      }
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final rgb = _convertYUV420ToImage(image);
      if (rgb == null) return;

      final centerX = rgb.width ~/ 2;
      final centerY = rgb.height ~/ 2;
      final regionSize = 10; // Even larger for stability

      List<int> reds = [];
      List<int> greens = [];
      List<int> blues = [];

      // Sample center region
      for (int dy = -regionSize; dy <= regionSize; dy++) {
        for (int dx = -regionSize; dx <= regionSize; dx++) {
          final x = (centerX + dx).clamp(0, rgb.width - 1);
          final y = (centerY + dy).clamp(0, rgb.height - 1);
          final pixel = rgb.getPixel(x, y);

          reds.add(pixel.r.toInt());
          greens.add(pixel.g.toInt());
          blues.add(pixel.b.toInt());
        }
      }

      // Use median for better accuracy
      final avgR = _median(reds);
      final avgG = _median(greens);
      final avgB = _median(blues);

      // Apply adaptive brightness boost for dim lighting
      final brightness = 0.299 * avgR + 0.587 * avgG + 0.114 * avgB;
      double boostFactor = 1.0;

      if (brightness < 30) {
        boostFactor = 3.0; // Strong boost for very dim
      } else if (brightness < 60) {
        boostFactor = 2.2; // Medium boost
      } else if (brightness < 100) {
        boostFactor = 1.5; // Light boost
      }

      // Apply boost while preserving color ratios
      int boostedR = (avgR * boostFactor).clamp(0, 255).toInt();
      int boostedG = (avgG * boostFactor).clamp(0, 255).toInt();
      int boostedB = (avgB * boostFactor).clamp(0, 255).toInt();

      // Enhance saturation for better color detection
      final pixelColor = Color.fromARGB(255, boostedR, boostedG, boostedB);
      final hsl = HSLColor.fromColor(pixelColor);

      // Boost saturation for dim colors
      double newSaturation = hsl.saturation;
      if (brightness < 80 && hsl.saturation > 0.1) {
        newSaturation = (hsl.saturation * 1.8).clamp(0.0, 1.0);
      }

      final enhancedHsl = hsl.withSaturation(newSaturation);

      String matchedColorName;
      Color matchedColor;

      // More aggressive thresholds to avoid gray/black/brown bias
      if (hsl.lightness < 0.12 && hsl.saturation < 0.15) {
        // Only truly dark colors are black
        matchedColorName = 'black';
        matchedColor = simplifiedColors.firstWhere(
          (c) => c.containsKey('black'),
        )['black']!;
      } else if (hsl.lightness > 0.88) {
        // Only very bright colors are white
        matchedColorName = 'white';
        matchedColor = simplifiedColors.firstWhere(
          (c) => c.containsKey('white'),
        )['white']!;
      } else if (hsl.saturation < 0.12 &&
          hsl.lightness > 0.25 &&
          hsl.lightness < 0.75) {
        // Only neutral mid-tones are gray
        matchedColorName = 'gray';
        matchedColor = simplifiedColors.firstWhere(
          (c) => c.containsKey('gray'),
        )['gray']!;
      } else {
        // Use enhanced color for chromatic matching
        double minDistance = double.infinity;
        matchedColorName = 'red';
        matchedColor = simplifiedColors.first.values.first;

        for (var colorMap in simplifiedColors) {
          final entry = colorMap.entries.first;
          if (entry.key == 'black' ||
              entry.key == 'white' ||
              entry.key == 'gray') {
            continue;
          }

          final targetColor = entry.value;
          // Use enhanced color for better dim light performance
          final distance = _colorDistanceHSL(
            enhancedHsl,
            HSLColor.fromColor(targetColor),
          );

          if (distance < minDistance) {
            minDistance = distance;
            matchedColorName = entry.key;
            matchedColor = targetColor;
          }
        }
      }

      if (mounted) {
        setState(() {
          _sampledColor = matchedColor;
          _colorName = matchedColorName;
          _r = avgR;
          _g = avgG;
          _b = avgB;
        });
      }
    } catch (e) {
      debugPrint('❌ Error processing frame: $e');
    } finally {
      _isProcessing = false;
    }
  }

  // HSL-based color distance for better dim light matching
  double _colorDistanceHSL(HSLColor c1, HSLColor c2) {
    // Hue distance (circular)
    double hueDiff = (c1.hue - c2.hue).abs();
    if (hueDiff > 180) hueDiff = 360 - hueDiff;
    hueDiff = hueDiff / 180.0; // Normalize to 0-1

    // Saturation and lightness differences
    double satDiff = (c1.saturation - c2.saturation).abs();
    double lightDiff = (c1.lightness - c2.lightness).abs();

    // Weight hue heavily for chromatic colors
    return sqrt(
      hueDiff * hueDiff * 3.0 + // Hue is most important
          satDiff * satDiff * 0.5 +
          lightDiff * lightDiff * 0.5,
    );
  }

  int _median(List<int> values) {
    if (values.isEmpty) return 0;
    values.sort();
    int mid = values.length ~/ 2;
    if (values.length % 2 == 1) return values[mid];
    return ((values[mid - 1] + values[mid]) / 2).round();
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

  @override
  void dispose() {
    _controller?.dispose();
    _ttsTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  // ---------------- COLOR FILTER / SIMULATION ----------------
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

  // ---------------- BUILD ----------------
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
                // Center circle
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
                // Color card at top
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
                              color: _sampledColor,
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
                                  _colorName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
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
                          if (widget.assistiveMode && _ttsReady)
                            IconButton(
                              icon: Icon(
                                _isSpeakingContinuously
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: _isSpeakingContinuously
                                    ? Colors.red
                                    : Colors.blue,
                                size: 28,
                              ),
                              onPressed: _toggleContinuousTTS,
                              tooltip: _isSpeakingContinuously
                                  ? 'Stop audio'
                                  : 'Start audio',
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
                        color: Colors.black.withOpacity(0.8),
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
                                      ? "1. Tap START to begin\n2. Point the center circle at objects\n3. See color name appear at top\n4. Tap speaker icon to hear color"
                                      : "1. This shows how ${widget.simulationType} affects vision\n2. Tap START to identify colors\n3. Move camera to explore",
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
                // Bottom scanning button
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
                          Colors.black.withOpacity(0.8),
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
