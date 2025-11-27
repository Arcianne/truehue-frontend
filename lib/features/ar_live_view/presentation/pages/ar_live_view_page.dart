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

Future<void> openARLiveView(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final mode = prefs.getString('liveARMode') ?? 'Assistive';
  final colorBlindType = prefs.getString('colorBlindnessType') ?? 'Normal';
  final bool assistiveMode = mode == 'Assistive';
  String colorBlindTypeFormatted = colorBlindType.toLowerCase();

  if (assistiveMode && colorBlindTypeFormatted == 'normal') {
    colorBlindTypeFormatted = 'protanopia';
  }

  final String? simulationType = mode == 'Simulation'
      ? colorBlindTypeFormatted
      : null;

  if (!context.mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ArLiveViewPage(
        assistiveMode: assistiveMode,
        simulationType: simulationType,
        colorBlindType: colorBlindTypeFormatted,
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
  Navigator.popUntil(context, (route) => route.isFirst);
}

class ArLiveViewPage extends StatefulWidget {
  final bool assistiveMode;
  final String? simulationType;
  final String? assistiveType;
  final String colorBlindType;

  const ArLiveViewPage({
    super.key,
    required this.assistiveMode,
    this.simulationType,
    this.assistiveType,
    this.colorBlindType = 'normal',
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

  // New controls for simulation mode
  bool _isSplitMode = false;
  bool _colorDetectionEnabled = true;
  String _currentSimulationType = 'protanopia';

  // Assistive mode controls
  bool _assistiveFilterEnabled = true;
  String _assistiveColorBlindType = 'protanopia';

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
    _currentSimulationType = widget.simulationType ?? 'protanopia';
    _assistiveColorBlindType = widget.colorBlindType;

    // ADD THIS DEBUG LINE
  debugPrint("🔍 Assistive Color Blind Type: $_assistiveColorBlindType");
  debugPrint("🔍 Widget Color Blind Type: ${widget.colorBlindType}");

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

      setState(() => _ttsReady = true);
    } catch (e) {
      debugPrint("❌ TTS initialization error: $e");
      setState(() => _ttsReady = false);
    }
  }

  void _toggleContinuousTTS() async {
    if (!_ttsReady) return;

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
    // Skip processing if color detection is disabled or in split mode
    if (!_colorDetectionEnabled || (_isSplitMode && !widget.assistiveMode)) {
      _isProcessing = false;
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastFrameProcessed).inMilliseconds < 100) return;
    _lastFrameProcessed = now;

    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final rgb = _convertYUV420ToImage(image);
      if (rgb == null) return;

      // ------------------ Weighted Average Sampling ------------------
      final centerX = rgb.width ~/ 2;
      final centerY = rgb.height ~/ 2;
      const radius = 3;

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

      // ------------------ KNN Color Matching  ------------------
      final colorFamily = ColorMatcher.getColorFamily(
        smoothedR,
        smoothedG,
        smoothedB,
      );

      final displayColor = Color.fromARGB(255, smoothedR, smoothedG, smoothedB);

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

ColorFilter _getAssistiveColorFilter(String type) {
    switch (type.toLowerCase()) {
      case 'protanopia': // B&W + POP RED
        return const ColorFilter.matrix([
          // R' = Keep original red channel (pop red)
          1.0, 0, 0, 0, 0,
          // G' = Grayscale (desaturate green/blue)
          0.299, 0.587, 0.114, 0, 0,
          // B' = Grayscale
          0.299, 0.587, 0.114, 0, 0,
          // A
          0, 0, 0, 1, 0,
        ]);

      case 'deuteranopia': // B&W + POP GREEN
        return const ColorFilter.matrix([
          // R' = Grayscale
          0.299, 0.587, 0.114, 0, 0,
          // G' = Keep original green channel (pop green)
          0, 1.0, 0, 0, 0,
          // B' = Grayscale
          0.299, 0.587, 0.114, 0, 0,
          // A
          0, 0, 0, 1, 0,
        ]);

      case 'tritanopia': // B&W + POP BLUE
        return const ColorFilter.matrix([
          // R' = Grayscale
          0.299, 0.587, 0.114, 0, 0,
          // G' = Grayscale
          0.299, 0.587, 0.114, 0, 0,
          // B' = Keep original blue channel (pop blue)
          0, 0, 1.0, 0, 0,
          // A
          0, 0, 0, 1, 0,
        ]);

      default:
        return const ColorFilter.matrix([
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
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

  ColorFilter _getColorFilter(String type) {
    switch (type.toLowerCase()) {
      case 'deuteranopia':
        return const ColorFilter.matrix([
          0.625,
          0.375,
          0.000,
          0,
          0,
          0.700,
          0.300,
          0.000,
          0,
          0,
          0.000,
          0.300,
          0.700,
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
          0.950,
          0.050,
          0.000,
          0,
          0,
          0.000,
          0.433,
          0.567,
          0,
          0,
          0.000,
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
          0.000,
          0,
          0,
          0.558,
          0.442,
          0.000,
          0,
          0,
          0.000,
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


  String _getColorBlindnessLabel(String type) {
    switch (type) {
      case 'deuteranopia':
        return 'Deuteranopia';
      case 'tritanopia':
        return 'Tritanopia';
      case 'protanopia':
      default:
        return 'Protanopia';
    }
  }

  String _getHighlightedColorName(String type) {
    switch (type) {
      case 'protanopia':
        return 'Red';
      case 'deuteranopia':
        return 'Green';
      case 'tritanopia':
        return 'Blue and Yellow';
      default:
        return 'Color';
    }
  }

  void _showColorBlindnessMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF130E64),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Color Blindness Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 13),
            _buildColorBlindnessOption(
              'protanopia',
              'Protanopia (difficulty distinguishing red hues)',
            ),
            _buildColorBlindnessOption(
              'deuteranopia',
              'Deuteranopia (difficulty distinguishing green hues)',
            ),
            _buildColorBlindnessOption(
              'tritanopia',
              'Tritanopia (difficulty distinguishing blue and yellow hues)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorBlindnessOption(String type, String label) {
    final isSelected = _currentSimulationType == type;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _currentSimulationType = type);
        Navigator.pop(context);
      },
    );
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
                // Camera preview (full or split)
                if (widget.assistiveMode)
                  // Assistive mode with optional filter
                  Positioned.fill(
                    child: _assistiveFilterEnabled
                        ? ColorFiltered(
                            colorFilter: _getAssistiveColorFilter(
                              _assistiveColorBlindType,
                            ),
                            child: CameraPreview(_controller!),
                          )
                        : CameraPreview(_controller!),
                  )
                else if (!_isSplitMode)
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: _getColorFilter(
                        _currentSimulationType,
                      ),
                      child: CameraPreview(_controller!),
                    ),
                  )
                else
                  // Split mode for simulation
                  Row(
                    children: [
                      // Normal view (left)
                      Expanded(
                        child: Stack(
                          children: [
                            CameraPreview(_controller!),
                            Positioned(
                              top: 40,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Normal Vision',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(width: 2, color: Colors.white),
                      // Simulated view (right)
                      Expanded(
                        child: Stack(
                          children: [
                            ColorFiltered(
                              colorFilter: _getColorFilter(
                                _currentSimulationType,
                              ),
                              child: CameraPreview(_controller!),
                            ),
                            Positioned(
                              top: 40,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getColorBlindnessLabel(
                                      _currentSimulationType,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // Assistive mode controls (top right)
                if (widget.assistiveMode)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Filter toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _assistiveFilterEnabled
                                  ? Icons.filter_alt
                                  : Icons.filter_alt_outlined,
                              color: _assistiveFilterEnabled
                                  ? Colors.green
                                  : Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _assistiveFilterEnabled = !_assistiveFilterEnabled;
                              });
                            },
                            tooltip: _assistiveFilterEnabled
                                ? 'Disable Filter'
                                : 'Enable Filter',
                          ),
                        ),
                      ],
                    ),
                  ),

                // Simulation mode controls (top right)
                if (!widget.assistiveMode)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Split mode toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isSplitMode ? Icons.fullscreen : Icons.compare,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() => _isSplitMode = !_isSplitMode);
                            },
                            tooltip: _isSplitMode
                                ? 'Full Screen'
                                : 'Split View',
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Color blindness type selector
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.palette,
                              color: Colors.white,
                            ),
                            onPressed: _showColorBlindnessMenu,
                            tooltip: 'Change Type',
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Color detection toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _colorDetectionEnabled
                                  ? Icons.colorize
                                  : Icons.colorize_outlined,
                              color: _colorDetectionEnabled
                                  ? Colors.green
                                  : Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _colorDetectionEnabled =
                                    !_colorDetectionEnabled;
                                if (!_colorDetectionEnabled) {
                                  _colorFamily = "";
                                  _sampledColor = Colors.transparent;
                                }
                              });
                            },
                            tooltip: 'Toggle Color Detection',
                          ),
                        ),
                      ],
                    ),
                  ),

                // Filter info badge (assistive mode)
                if (widget.assistiveMode && _assistiveFilterEnabled)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Highlighting ${_getHighlightedColorName(_assistiveColorBlindType)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Center circle (only if not in split mode or in assistive mode)
                if (widget.assistiveMode ||
                    (!_isSplitMode && _colorDetectionEnabled))
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
                if (_isScanning &&
                    _colorFamily.isNotEmpty &&
                    _colorDetectionEnabled &&
                    !_isSplitMode)
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
                          if (_ttsReady)
                            IconButton(
                              icon: Icon(
                                Icons.volume_up,
                                color: _isSpeakingContinuously
                                    ? Colors.blue
                                    : Colors.grey,
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
                                      ? "1. Tap filter icon to enable/disable color highlighting\n2. Your color type (${_getColorBlindnessLabel(_assistiveColorBlindType)}) is set in Settings\n3. Everything will be grayscale except the problematic color\n4. Tap START to begin color detection\n5. Point center circle at objects to identify colors"
                                      : "1. Use split view to compare normal vs simulated vision\n2. Change color blindness type with palette icon\n3. Toggle color detection on/off\n4. Tap START to identify colors",
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

                // Bottom scanning button (only show if color detection is enabled and not in split mode)
                if (_colorDetectionEnabled && !_isSplitMode)
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