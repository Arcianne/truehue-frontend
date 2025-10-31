import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:truehue/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';
import 'package:truehue/core/algorithm/knn_color_matcher.dart';
import 'package:truehue/features/home/presentation/pages/home.dart';

Future<void> openARLiveView(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final mode = prefs.getString('liveARMode') ?? 'Assistive';
  final colorBlindType = prefs.getString('colorBlindnessType') ?? 'Normal';

  // Determine assistiveMode and simulationType based on settings
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

void openSelectAPhotoPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const SelectAPhotoPage()),
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

void openColorLibraryPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const ColorLibraryPage()),
  );
}

void openHomePage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const Home()),
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
  bool _showInstructions = true;

  Color _sampledColor = Colors.transparent;
  String _colorFamily = "";
  int _r = 0, _g = 0, _b = 0;
  String _previousColorFamily = "";
  bool _isSpeakingContinuously = false;
  Timer? _ttsTimer;

  // ------------------ Temporal smoothing ------------------
  final int _smoothingFrames = 5;
  final List<int> _rBuffer = [];
  final List<int> _gBuffer = [];
  final List<int> _bBuffer = [];

  // ------------------ Frame throttling ------------------
  DateTime _lastFrameProcessed = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeCamera();
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showInstructions = false);
    });
  }

  // ------------------ TTS ------------------
  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() => debugPrint("✅ TTS completed"));
      _tts.setErrorHandler((msg) => debugPrint("❌ TTS Error: $msg"));

      setState(() => _ttsReady = true);
    } catch (e) {
      debugPrint("❌ TTS initialization error: $e");
      setState(() => _ttsReady = false);
    }
  }

  void _toggleContinuousTTS() async {
    if (!_ttsReady || !widget.assistiveMode) return;

    if (_isSpeakingContinuously) {
      _ttsTimer?.cancel();
      await _tts.stop();
      setState(() => _isSpeakingContinuously = false);
    } else {
      setState(() => _isSpeakingContinuously = true);
      _previousColorFamily = "";
      if (_colorFamily.isNotEmpty) await _speakColor(_colorFamily);

      _ttsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        if (!_isSpeakingContinuously || !mounted) return;
        if (_colorFamily.isNotEmpty && _colorFamily != _previousColorFamily) {
          await _speakColor(_colorFamily);
        }
      });
    }
  }

  Future<void> _speakColor(String color) async {
    if (!_ttsReady) return;
    _previousColorFamily = color;
    try {
      await _tts.stop();
      await Future.delayed(const Duration(milliseconds: 50));
      await _tts.speak(color);
    } catch (e) {
      debugPrint("❌ Error speaking: $e");
    }
  }

  // ------------------ Camera ------------------
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
        _colorFamily = "";
        _sampledColor = Colors.transparent;
      });

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
    final now = DateTime.now();
    if (now.difference(_lastFrameProcessed).inMilliseconds < 100) return;
    _lastFrameProcessed = now;

    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final rgb = _convertYUV420ToImage(image);
      if (rgb == null) return;

      // ------------------ Weighted Average Sampling (EXACTLY like Take A Photo) ------------------
      final centerX = rgb.width ~/ 2;
      final centerY = rgb.height ~/ 2;
      const radius = 3; // Same as take-a-photo default

      int r = 0, g = 0, b = 0, totalWeight = 0;

      for (int dx = -radius; dx <= radius; dx++) {
        for (int dy = -radius; dy <= radius; dy++) {
          int distance = dx.abs() + dy.abs();
          int weight = (radius * 2 + 1) - distance;

          int x = (centerX + dx).clamp(0, rgb.width - 1);
          int y = (centerY + dy).clamp(0, rgb.height - 1);

          final pixel = rgb.getPixel(x, y);
          r += pixel.r.toInt() * weight;
          g += pixel.g.toInt() * weight;
          b += pixel.b.toInt() * weight;
          totalWeight += weight;
        }
      }

      if (totalWeight == 0) {
        _isProcessing = false;
        return;
      }

      final avgR = r ~/ totalWeight;
      final avgG = g ~/ totalWeight;
      final avgB = b ~/ totalWeight;

      // ------------------ Temporal Smoothing ------------------
      _rBuffer.add(avgR);
      _gBuffer.add(avgG);
      _bBuffer.add(avgB);
      if (_rBuffer.length > _smoothingFrames) _rBuffer.removeAt(0);
      if (_gBuffer.length > _smoothingFrames) _gBuffer.removeAt(0);
      if (_bBuffer.length > _smoothingFrames) _bBuffer.removeAt(0);

      final smoothedR = (_rBuffer.reduce((a, b) => a + b) / _rBuffer.length)
          .round();
      final smoothedG = (_gBuffer.reduce((a, b) => a + b) / _gBuffer.length)
          .round();
      final smoothedB = (_bBuffer.reduce((a, b) => a + b) / _bBuffer.length)
          .round();

      // ------------------ KNN Color Matching (Let KNN handle EVERYTHING) ------------------
      final colorFamily = ColorMatcher.getColorFamily(
        smoothedR,
        smoothedG,
        smoothedB,
      );

      final displayColor = Color.fromARGB(255, smoothedR, smoothedG, smoothedB);

      // ------------------ Update UI ------------------
      const threshold = 5;
      if ((_r - smoothedR).abs() > threshold ||
          (_g - smoothedG).abs() > threshold ||
          (_b - smoothedB).abs() > threshold ||
          _colorFamily != colorFamily) {
        if (mounted) {
          setState(() {
            _sampledColor = displayColor;
            _colorFamily = colorFamily;
            _r = smoothedR;
            _g = smoothedG;
            _b = smoothedB;
          });
        }
      }
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
  void dispose() {
    _controller?.dispose();
    _ttsTimer?.cancel();
    _tts.stop();
    super.dispose();
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
                // Color card
                if (_isScanning && _colorFamily.isNotEmpty)
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
                                  _colorFamily.toUpperCase(),
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
                                      ? "1. Tap START to begin\n2. Point the center circle at objects\n3. See color family appear at top\n4. Tap speaker icon to hear color"
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
              onTap: () => openHomePage(context),
            ),
          ],
        ),
      ),
    );
  }
}
