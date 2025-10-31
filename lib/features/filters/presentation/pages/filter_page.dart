import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truehue/core/algorithm/knn_color_matcher.dart';

enum FilterMode { none, spot, recolor }

// ---------------- LAB COLOR CLASS (MOVED TO TOP-LEVEL) ----------------
class LabColor {
  final double l;
  final double a;
  final double b;
  LabColor(this.l, this.a, this.b);
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

  // Color picking - NOW STORES IMAGE COORDINATES
  Offset? _tapPosition; // Image coordinates (pixel X, Y)
  Color _pickedColor = Colors.white;
  String _colorName = "";
  String _colorFamily = "";
  int _r = 0, _g = 0, _b = 0;

  // Spot filter
  final Set<Color> _spotColors = {};

  // Recolor filter
  Color _recolorTargetColor = Colors.red;
  Offset? _recolorTapPosition; // Image coordinates

  // UI state
  final GlobalKey _imageKey = GlobalKey();
  bool _isProcessing = false;
  bool _isSaving = false;

  // REDUCED tolerance for more precise color matching
  final double _colorTolerance = 8.0;

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

  // ---------------- LAB COLOR DISTANCE (Delta E) ----------------
  LabColor rgbToLab(Color color) {
    double r = color.red / 255;
    double g = color.green / 255;
    double b = color.blue / 255;

    r = r > 0.04045 ? pow((r + 0.055) / 1.055, 2.4).toDouble() : r / 12.92;
    g = g > 0.04045 ? pow((g + 0.055) / 1.055, 2.4).toDouble() : g / 12.92;
    b = b > 0.04045 ? pow((b + 0.055) / 1.055, 2.4).toDouble() : b / 12.92;

    double x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047;
    double y = (0.2126729 * r + 0.7151522 * g + 0.0721750 * b) / 1.00000;
    double z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883;

    double f(double t) => t > 0.008856
        ? pow(t, 1.0 / 3.0).toDouble()
        : (7.787 * t) + 16.0 / 116.0;

    double fx = f(x);
    double fy = f(y);
    double fz = f(z);

    double lVal = (116 * fy) - 16;
    double aVal = 500 * (fx - fy);
    double bVal = 200 * (fy - fz);

    return LabColor(lVal, aVal, bVal);
  }

  double deltaE(Color c1, Color c2) {
    final lab1 = rgbToLab(c1);
    final lab2 = rgbToLab(c2);
    return sqrt(
      pow(lab1.l - lab2.l, 2) +
          pow(lab1.a - lab2.a, 2) +
          pow(lab1.b - lab2.b, 2),
    );
  }

  // ---------------- WEIGHTED AVERAGE PIXELS ----------------
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

        r += pixel.r.toInt() * weight;
        g += pixel.g.toInt() * weight;
        b += pixel.b.toInt() * weight;
        totalWeight += weight;
      }
    }

    if (totalWeight == 0) return Colors.black;

    return Color.fromARGB(
      255,
      (r / totalWeight).round().clamp(0, 255),
      (g / totalWeight).round().clamp(0, 255),
      (b / totalWeight).round().clamp(0, 255),
    );
  }

  // ---------------- TAP COORDINATE MAPPING ----------------
  Offset _mapTapToImage(
    Size widgetSize,
    int imageWidth,
    int imageHeight,
    Offset tap,
  ) {
    final imageRatio = imageWidth / imageHeight;
    final widgetRatio = widgetSize.width / widgetSize.height;

    double renderedWidth;
    double renderedHeight;
    double offsetX;
    double offsetY;

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

  // Map image coordinates back to screen position for accurate marker placement
  Offset _mapImageToScreen(
    Size widgetSize,
    int imageWidth,
    int imageHeight,
    Offset imagePos,
  ) {
    final imageRatio = imageWidth / imageHeight;
    final widgetRatio = widgetSize.width / widgetSize.height;

    double renderedWidth;
    double renderedHeight;
    double offsetX;
    double offsetY;

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

    final screenX = (imagePos.dx / imageWidth * renderedWidth) + offsetX;
    final screenY = (imagePos.dy / imageHeight * renderedHeight) + offsetY;

    return Offset(screenX, screenY);
  }

  // ---------------- SPOT FILTER ----------------
  img.Image _applySpotFilter(img.Image original, Set<Color> colorsToKeep) {
    final result = img.Image.from(original);
    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final pixel = result.getPixelSafe(x, y);
        final currentColor = Color.fromARGB(
          255,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );

        bool keep = colorsToKeep.any(
          (c) => deltaE(c, currentColor) < _colorTolerance,
        );

        if (!keep) {
          final gray = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114)
              .round();
          result.setPixelRgba(x, y, gray, gray, gray, 255);
        }
      }
    }
    return result;
  }

  // ---------------- IMPROVED RECOLOR FILTER ----------------
  Future<void> _applyRecolorFilter(Color targetColor) async {
    if (_baseImageForCurrentMode == null || _recolorTapPosition == null) return;

    setState(() => _isProcessing = true);
    try {
      final result = await _simulateRecolor(
        _baseImageForCurrentMode!,
        targetColor,
        _pickedColor,
      );

      setState(() {
        _displayImage = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recolor failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<img.Image> _simulateRecolor(
    img.Image original,
    Color targetColor,
    Color sourceColor,
  ) async {
    final result = img.Image.from(original);
    final targetHSV = HSVColor.fromColor(targetColor);
    final sourceHSV = HSVColor.fromColor(sourceColor);

    // Calculate hue shift
    final hueDiff = targetHSV.hue - sourceHSV.hue;

    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final pixel = result.getPixelSafe(x, y);
        final currentColor = Color.fromARGB(
          255,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );

        // Only recolor pixels that match the source color closely
        if (deltaE(currentColor, sourceColor) < _colorTolerance) {
          final hsv = HSVColor.fromColor(currentColor);

          // Apply hue shift while preserving the original saturation and value
          final newHue = (hsv.hue + hueDiff) % 360;

          final newColor = HSVColor.fromAHSV(
            1.0,
            newHue,
            hsv.saturation,
            hsv.value,
          ).toColor();

          result.setPixelRgba(
            x,
            y,
            newColor.red,
            newColor.green,
            newColor.blue,
            255,
          );
        }
      }
    }
    return result;
  }

  // ---------------- TAP HANDLER (FIXED) ----------------
  void _handleTap(TapDownDetails details) {
    if (_originalImage == null) return;

    final renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final widgetSize = renderBox.size;

    final mapped = _mapTapToImage(
      widgetSize,
      _originalImage!.width,
      _originalImage!.height,
      details.localPosition,
    );

    if (mapped.dx == -1 && mapped.dy == -1) {
      return;
    }

    final int pixelX = mapped.dx.round().clamp(0, _originalImage!.width - 1);
    final int pixelY = mapped.dy.round().clamp(0, _originalImage!.height - 1);

    final pickedColor = _weightedAveragePixels(_originalImage!, pixelX, pixelY);

    setState(() {
      // Store IMAGE coordinates (pixel X, Y) instead of screen coordinates
      _tapPosition = Offset(pixelX.toDouble(), pixelY.toDouble());
      _pickedColor = pickedColor;
      _colorName = ColorMatcher.getColorFamily(
        _pickedColor.red,
        _pickedColor.green,
        _pickedColor.blue,
      );
      _r = _pickedColor.red;
      _g = _pickedColor.green;
      _b = _pickedColor.blue;
      _colorFamily = ColorMatcher.getColorFamily(_r, _g, _b);

      if (_currentFilterMode == FilterMode.spot) {
        _spotColors.add(pickedColor);
        _displayImage = _applySpotFilter(
          _baseImageForCurrentMode!,
          _spotColors,
        );
      } else if (_currentFilterMode == FilterMode.recolor) {
        // Store image coordinates for recolor too
        _recolorTapPosition = Offset(pixelX.toDouble(), pixelY.toDouble());
        final hsv = HSVColor.fromColor(pickedColor);
        _recolorTargetColor = HSVColor.fromAHSV(
          1.0,
          hsv.hue,
          1.0,
          1.0,
        ).toColor();
        _applyRecolorFilter(_recolorTargetColor);
      }
    });
  }

  // ---------------- UI & SAVE HANDLERS ----------------
  void _switchFilterMode(FilterMode mode) {
    setState(() {
      _currentFilterMode = mode;
      if (_originalImage != null) {
        _displayImage = _originalImage!.clone();
        _baseImageForCurrentMode = _originalImage!.clone();
      }
      _spotColors.clear();
      _recolorTapPosition = null;
      _tapPosition = null;
      _colorName = "";
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
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
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
        ? 'Tap a color to begin recoloring'
        : 'Recoloring: $_colorName';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
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
                          Color(0xFFFF0000), // Red
                          Color(0xFFFF7F00), // Orange
                          Color(0xFFFFFF00), // Yellow
                          Color(0xFF00FF00), // Green
                          Color(0xFF00FFFF), // Cyan
                          Color(0xFF0000FF), // Blue
                          Color(0xFF8B00FF), // Purple
                          Color(0xFFFF00FF), // Magenta
                          Color(0xFFFF0000), // Red (loop)
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
                        },
                        onChangeEnd: (value) {
                          if (_colorName.isNotEmpty) {
                            _applyRecolorFilter(_recolorTargetColor);
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
                // Image display
                Center(
                  child: GestureDetector(
                    key: _imageKey,
                    onTapDown: _handleTap,
                    child: Image.memory(
                      img.encodePng(_displayImage!),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
                // Processing overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
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
                          Colors.black.withOpacity(0.7),
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
                // Color info card
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
                // Tap marker (DYNAMICALLY POSITIONED - FIXED)
                if (_tapPosition != null && _originalImage != null)
                  Builder(
                    builder: (context) {
                      final renderBox =
                          _imageKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (renderBox == null) return const SizedBox.shrink();

                      final widgetSize = renderBox.size;
                      // Convert stored image coordinates to current screen position
                      final screenPos = _mapImageToScreen(
                        widgetSize,
                        _originalImage!.width,
                        _originalImage!.height,
                        _tapPosition!,
                      );

                      return Positioned(
                        left: screenPos.dx - 15,
                        top: screenPos.dy - 15,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _pickedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
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
                                  ? 'Tap colors to keep (rest becomes grayscale)'
                                  : 'Tap a color, then slide to change its hue',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
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
