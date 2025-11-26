import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import 'package:truehue/core/algorithm/knn_color_matcher.dart';

enum FilterMode { none, spot, recolor }

// ---------------- LAB COLOR CLASS ----------------
class LabColor {
  final double l;
  final double a;
  final double b;
  LabColor(this.l, this.a, this.b);
}

// ---------------- ISOLATE DATA CLASSES ----------------
class RecolorData {
  final Uint8List imageBytes;
  final int width;
  final int height;
  final Color sourceColor;
  final double tolerance;

  RecolorData({
    required this.imageBytes,
    required this.width,
    required this.height,
    required this.sourceColor,
    required this.tolerance,
  });
}

class RecolorResult {
  final List<int> pixelIndices;
  final List<int> originalReds;
  final List<int> originalGreens;
  final List<int> originalBlues;

  RecolorResult({
    required this.pixelIndices,
    required this.originalReds,
    required this.originalGreens,
    required this.originalBlues,
  });
}

// ---------------- ISOLATE FUNCTIONS ----------------
Future<RecolorResult> _buildMaskInIsolate(RecolorData data) async {
  final image = img.Image.fromBytes(
    width: data.width,
    height: data.height,
    bytes: data.imageBytes.buffer,
  );

  final pixelIndices = <int>[];
  final originalReds = <int>[];
  final originalGreens = <int>[];
  final originalBlues = <int>[];

  // print(
  //   'Building mask for color: RGB(${data.sourceColor.red}, ${data.sourceColor.green}, ${data.sourceColor.blue}) with tolerance ${data.tolerance}',
  // );

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixelSafe(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final a = pixel.a.toInt(); // Get alpha channel

      // FIX: Skip transparent or nearly transparent pixels
      if (a < 50) continue;

      final currentColor = Color.fromARGB(255, r, g, b);
      final deltaEValue = _deltaE(currentColor, data.sourceColor);

      if (deltaEValue < data.tolerance) {
        pixelIndices.add(y * image.width + x);
        originalReds.add(r);
        originalGreens.add(g);
        originalBlues.add(b);
      }
    }
  }

  // print('Found ${pixelIndices.length} matching pixels');

  return RecolorResult(
    pixelIndices: pixelIndices,
    originalReds: originalReds,
    originalGreens: originalGreens,
    originalBlues: originalBlues,
  );
}

double _deltaE(Color c1, Color c2) {
  final lab1 = _rgbToLab(c1);
  final lab2 = _rgbToLab(c2);
  return sqrt(
    pow(lab1.l - lab2.l, 2) + pow(lab1.a - lab2.a, 2) + pow(lab1.b - lab2.b, 2),
  );
}

LabColor _rgbToLab(Color color) {
  double r = color.red / 255;
  double g = color.green / 255;
  double b = color.blue / 255;

  r = r > 0.04045 ? pow((r + 0.055) / 1.055, 2.4).toDouble() : r / 12.92;
  g = g > 0.04045 ? pow((g + 0.055) / 1.055, 2.4).toDouble() : g / 12.92;
  b = b > 0.04045 ? pow((b + 0.055) / 1.055, 2.4).toDouble() : b / 12.92;

  double x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047;
  double y = (0.2126729 * r + 0.7151522 * g + 0.0721750 * b) / 1.00000;
  double z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883;

  double f(double t) =>
      t > 0.008856 ? pow(t, 1.0 / 3.0).toDouble() : (7.787 * t) + 16.0 / 116.0;

  double fx = f(x);
  double fy = f(y);
  double fz = f(z);

  double lVal = (116 * fy) - 16;
  double aVal = 500 * (fx - fy);
  double bVal = 200 * (fy - fz);

  return LabColor(lVal, aVal, bVal);
}

class FilterPage extends StatefulWidget {
  final String imagePath;
  final String sourcePageTitle;
  const FilterPage({
    super.key,
    required this.imagePath,
    this.sourcePageTitle = "Photo",
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  img.Image? _originalImage;
  img.Image? _displayImage;
  img.Image? _baseImageForCurrentMode;
  FilterMode _currentFilterMode = FilterMode.none;

  Offset? _tapScreenPosition;
  // ignore: unused_field
  Offset? _tapImagePosition;
  Color _pickedColor = Colors.white;
  String _colorName = "";
  String _colorFamily = "";
  int _r = 0, _g = 0, _b = 0;

  Color? _currentSpotColor;

  Color _recolorTargetColor = Colors.red;
  // ignore: unused_field
  Offset? _recolorScreenPosition;
  Offset? _recolorImagePosition;
  img.Image? _cachedRecolorMask;
  List<int>? _pixelsToRecolor;
  List<int>? _originalReds;
  List<int>? _originalGreens;
  List<int>? _originalBlues;

  final GlobalKey _imageKey = GlobalKey();
  bool _isProcessing = false;
  bool _isSaving = false;

  final double _colorTolerance =
      40.0; // Increased tolerance for better color matching

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await File(widget.imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      setState(() {
        _originalImage = decoded;
        _displayImage = decoded.clone();
        _baseImageForCurrentMode = decoded.clone();
      });
    }
  }

  LabColor rgbToLab(Color color) => _rgbToLab(color);
  double deltaE(Color c1, Color c2) => _deltaE(c1, c2);

  Color _weightedAveragePixels(
    img.Image image,
    int x,
    int y, {
    int radius = 1,
  }) {
    x = x.clamp(0, image.width - 1);
    y = y.clamp(0, image.height - 1);

    int r = 0, g = 0, b = 0, totalWeight = 0;

    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        int distance = dx.abs() + dy.abs();
        int weight = (radius * 2 + 1) - distance;

        int px = (x + dx).clamp(0, image.width - 1);
        int py = (y + dy).clamp(0, image.height - 1);

        final pixel = image.getPixelSafe(px, py);

        // Ensure we're getting RGB values correctly
        r += pixel.r.toInt() * weight;
        g += pixel.g.toInt() * weight;
        b += pixel.b.toInt() * weight;
        totalWeight += weight;
      }
    }

    if (totalWeight == 0) return Colors.black;

    final avgR = (r / totalWeight).round().clamp(0, 255);
    final avgG = (g / totalWeight).round().clamp(0, 255);
    final avgB = (b / totalWeight).round().clamp(0, 255);

    // Debug print
    // print('Picked color at ($x, $y): RGB($avgR, $avgG, $avgB)');

    return Color.fromARGB(255, avgR, avgG, avgB);
  }

  Offset _mapTapToImage(
    Size widgetSize,
    int imageWidth,
    int imageHeight,
    Offset tap,
  ) {
    final imageRatio = imageWidth / imageHeight;
    final widgetRatio = widgetSize.width / widgetSize.height;

    double renderedWidth, renderedHeight, offsetX, offsetY;

    if (imageRatio > widgetRatio) {
      renderedWidth = widgetSize.width;
      renderedHeight = widgetSize.width / imageRatio;
      offsetX = 0;
      offsetY = (widgetSize.height - renderedHeight) / 2;
    } else {
      renderedHeight = widgetSize.height;
      renderedWidth = widgetSize.height * imageRatio;
      offsetX = (widgetSize.width - renderedWidth) / 2;
      offsetY = 0;
    }

    if (tap.dx < offsetX ||
        tap.dx > offsetX + renderedWidth ||
        tap.dy < offsetY ||
        tap.dy > offsetY + renderedHeight) {
      return const Offset(-1, -1);
    }

    final relativeX = tap.dx - offsetX;
    final relativeY = tap.dy - offsetY;

    final imageX = (relativeX / renderedWidth * imageWidth).clamp(
      0.0,
      imageWidth - 1.0,
    );
    final imageY = (relativeY / renderedHeight * imageHeight).clamp(
      0.0,
      imageHeight - 1.0,
    );

    return Offset(imageX, imageY);
  }

  img.Image _applySpotFilter(img.Image original, Color colorToKeep) {
    final result = img.Image.from(original);
    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final pixel = result.getPixelSafe(x, y);
        final a = pixel.a.toInt();

        // FIX: Skip transparent pixels
        if (a < 50) continue;

        final currentColor = Color.fromARGB(
          255,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );

        bool keep = deltaE(colorToKeep, currentColor) < _colorTolerance;

        if (!keep) {
          final gray = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114)
              .round();
          result.setPixelRgba(x, y, gray, gray, gray, a); // Preserve alpha
        }
      }
    }
    return result;
  }

  Future<void> _buildRecolorMask(Color sourceColor) async {
    if (_originalImage == null) return;

    // FIX: Always use original image for mask detection
    final original = _originalImage!;

    final data = RecolorData(
      imageBytes: Uint8List.fromList(original.getBytes()),
      width: original.width,
      height: original.height,
      sourceColor: sourceColor,
      tolerance: _colorTolerance,
    );

    final result = await compute(_buildMaskInIsolate, data);

    setState(() {
      _pixelsToRecolor = result.pixelIndices;
      _originalReds = result.originalReds;
      _originalGreens = result.originalGreens;
      _originalBlues = result.originalBlues;
      // FIX: Cache original image for recoloring
      _cachedRecolorMask = _originalImage!.clone();
    });
  }

  void _applyFastRecolor(double targetHue) {
    if (_cachedRecolorMask == null || _pixelsToRecolor == null) return;

    final result = _cachedRecolorMask!.clone();

    for (int i = 0; i < _pixelsToRecolor!.length; i++) {
      final index = _pixelsToRecolor![i];
      final x = index % result.width;
      final y = index ~/ result.width;

      // Get original pixel to preserve alpha
      final originalPixel = result.getPixelSafe(x, y);
      final originalAlpha = originalPixel.a.toInt();

      // FIX: Use stored original colors for consistent recoloring
      final currentColor = Color.fromARGB(
        255,
        _originalReds![i],
        _originalGreens![i],
        _originalBlues![i],
      );

      final hsv = HSVColor.fromColor(currentColor);

      // FIX: Better hue calculation - shift relative to picked color
      final pickedHsv = HSVColor.fromColor(_pickedColor);
      final hueDiff = targetHue - pickedHsv.hue;
      final newHue = (hsv.hue + hueDiff) % 360;

      // FIX: Preserve original saturation and value for more natural results
      final newColor = HSVColor.fromAHSV(
        1.0,
        newHue,
        hsv.saturation, // Keep original saturation
        hsv.value, // Keep original brightness
      ).toColor();

      // FIX: Preserve original alpha channel for transparent PNGs
      result.setPixelRgba(
        x,
        y,
        newColor.red,
        newColor.green,
        newColor.blue,
        originalAlpha,
      );
    }

    setState(() {
      _displayImage = result;
    });
  }

  Future<void> _initializeRecolor() async {
    if (_originalImage == null || _recolorImagePosition == null) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _buildRecolorMask(_pickedColor);

      // Debug: Check if pixels were found
      if (_pixelsToRecolor == null || _pixelsToRecolor!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No similar colors found. Try a different area or increase tolerance.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Apply the recolor
        _applyFastRecolor(HSVColor.fromColor(_recolorTargetColor).hue);

        // Debug: Show how many pixels were found
        // print('Recoloring ${_pixelsToRecolor!.length} pixels');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recolor failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _updateColorAtPosition(Offset localPosition) {
    if (_originalImage == null) return;

    final renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final globalTapPos = renderBox.localToGlobal(localPosition);
    final stackBox = context.findRenderObject() as RenderBox?;
    final stackLocalPos =
        stackBox?.globalToLocal(globalTapPos) ?? localPosition;

    final widgetSize = renderBox.size;
    final imagePos = _mapTapToImage(
      widgetSize,
      _originalImage!.width,
      _originalImage!.height,
      localPosition,
    );

    if (imagePos.dx == -1 && imagePos.dy == -1) return;

    final int pixelX = imagePos.dx.round().clamp(0, _originalImage!.width - 1);
    final int pixelY = imagePos.dy.round().clamp(0, _originalImage!.height - 1);

    final pickedColor = _weightedAveragePixels(_originalImage!, pixelX, pixelY);

    setState(() {
      _tapScreenPosition = stackLocalPos;
      _tapImagePosition = Offset(pixelX.toDouble(), pixelY.toDouble());
      _pickedColor = pickedColor;

      _r = _pickedColor.red;
      _g = _pickedColor.green;
      _b = _pickedColor.blue;

      // FIX: Properly assign color name and family
      _colorFamily = ColorMatcher.getColorFamily(_r, _g, _b);
      _colorName =
          _colorFamily; // Use family as name if no specific name method exists

      if (_currentFilterMode == FilterMode.recolor) {
        _recolorScreenPosition = stackLocalPos;
        _recolorImagePosition = Offset(pixelX.toDouble(), pixelY.toDouble());
        final hsv = HSVColor.fromColor(pickedColor);
        _recolorTargetColor = HSVColor.fromAHSV(
          1.0,
          hsv.hue,
          1.0,
          1.0,
        ).toColor();
        _initializeRecolor();
      }
    });
  }

  void _handlePanStart(DragStartDetails details) {
    _updateColorAtPosition(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updateColorAtPosition(details.localPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_currentFilterMode == FilterMode.spot && _pickedColor != Colors.white) {
      setState(() {
        _currentSpotColor = _pickedColor;
        _displayImage = _applySpotFilter(
          _baseImageForCurrentMode!,
          _currentSpotColor!,
        );
      });
    }
  }

  void _handleTap(TapDownDetails details) {
    _updateColorAtPosition(details.localPosition);

    if (_currentFilterMode == FilterMode.spot) {
      setState(() {
        _currentSpotColor = _pickedColor;
        _displayImage = _applySpotFilter(
          _baseImageForCurrentMode!,
          _currentSpotColor!,
        );
      });
    }
  }

  void _switchFilterMode(FilterMode mode) {
    setState(() {
      _currentFilterMode = mode;
      if (_originalImage != null) {
        _displayImage = _originalImage!.clone();
        _baseImageForCurrentMode = _originalImage!.clone();
      }
      _currentSpotColor = null;
      _recolorScreenPosition = null;
      _recolorImagePosition = null;
      _tapScreenPosition = null;
      _tapImagePosition = null;
      _colorName = "";
      _pixelsToRecolor = null;
      _cachedRecolorMask = null;
      _originalReds = null;
      _originalGreens = null;
      _originalBlues = null;
    });
  }

  Future<void> _saveImage() async {
    if (_displayImage == null) return;
    setState(() => _isSaving = true);
    try {
      await Gal.requestAccess();
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final encodedImage = img.encodeJpg(_displayImage!);
      await File(tempPath).writeAsBytes(encodedImage);
      await Gal.putImage(tempPath, album: 'TrueHue');
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
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _freezeAndNavigateBack() async {
    if (_displayImage != null) {
      try {
        final tempDir = await getTemporaryDirectory();
        final freezePath =
            '${tempDir.path}/freeze_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final encodedImage = img.encodeJpg(_displayImage!);
        await File(freezePath).writeAsBytes(encodedImage);
        if (mounted) {
          Navigator.pop(context, freezePath);
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildModeButton(String label, FilterMode mode) {
    final isSelected = _currentFilterMode == mode;
    return GestureDetector(
      onTap: () => _switchFilterMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildColorSlider() {
    String sliderTitle = _colorName.isEmpty
        ? 'Tap or glide over a color to begin recoloring'
        : 'Recoloring: $_colorName';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            sliderTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_colorName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF0000),
                          Color(0xFFFF7F00),
                          Color(0xFFFFFF00),
                          Color(0xFF00FF00),
                          Color(0xFF00FFFF),
                          Color(0xFF0000FF),
                          Color(0xFF8B00FF),
                          Color(0xFFFF00FF),
                          Color(0xFFFF0000),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 14,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 24,
                        ),
                        trackHeight: 40,
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: HSVColor.fromColor(_recolorTargetColor).hue,
                        min: 0,
                        max: 360,
                        onChanged: (value) {
                          setState(() {
                            _recolorTargetColor = HSVColor.fromAHSV(
                              1.0,
                              value,
                              1.0,
                              1.0,
                            ).toColor();
                          });
                          if (_pixelsToRecolor != null) {
                            _applyFastRecolor(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _recolorTargetColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _originalImage == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: GestureDetector(
                    key: _imageKey,
                    onTapDown: _handleTap,
                    onPanStart: _handlePanStart,
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: _handlePanEnd,
                    child: Image.memory(
                      img.encodePng(_displayImage!),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Applying filter...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filter ${widget.sourcePageTitle}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download, color: Colors.white),
                          onPressed: _isSaving ? null : _saveImage,
                          tooltip: 'Save to Gallery',
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: _freezeAndNavigateBack,
                          tooltip: 'Done',
                        ),
                      ],
                    ),
                  ),
                ),
                if (_colorName.isNotEmpty &&
                    _currentFilterMode != FilterMode.none)
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
                if (_tapScreenPosition != null)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 50),
                    left: _tapScreenPosition!.dx - 15,
                    top: _tapScreenPosition!.dy - 15,
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
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      top: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentFilterMode == FilterMode.recolor) ...[
                          _buildColorSlider(),
                          const SizedBox(height: 16),
                        ],
                        if (_currentFilterMode != FilterMode.none)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _currentFilterMode == FilterMode.spot
                                  ? 'Tap or glide over a color to spotlight it (rest becomes grayscale)'
                                  : 'Tap or glide over a color, then slide to change its hue',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildModeButton('Actual', FilterMode.none),
                            const SizedBox(width: 8),
                            _buildModeButton('Recolor', FilterMode.recolor),
                            const SizedBox(width: 8),
                            _buildModeButton('Spot', FilterMode.spot),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
