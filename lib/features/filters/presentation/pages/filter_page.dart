import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:colornames/colornames.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

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

  // Color picking
  Offset? _tapPosition;
  Color _pickedColor = Colors.white;
  String _colorName = "";
  String _colorFamily = "";
  int _r = 0, _g = 0, _b = 0;

  // Spot filter
  final Set<Color> _spotColors = {};

  // Recolor filter
  Color _recolorTargetColor = Colors.red;
  Offset? _recolorTapPosition;

  // UI state
  final GlobalKey _imageKey = GlobalKey();
  bool _isProcessing = false;
  bool _isSaving = false;

  // Default Delta E tolerance for filtering.
  // A value between 5 and 15 is generally good.
  final double _colorTolerance = 15.0;

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
        // Using clone() for reliable deep copying.
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

    // D65 standard illuminant
    double x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047;
    double y = (0.2126729 * r + 0.7151522 * g + 0.0721750 * b) / 1.00000;
    double z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883;

    // f(t) function
    double f(double t) => t > 0.008856
        ? pow(t, 1.0 / 3.0).toDouble()
        : (7.787 * t) + 16.0 / 116.0;

    double fx = f(x);
    double fy = f(y);
    double fz = f(z);

    double lVal = (116 * fy) - 16;
    double aVal = 500 * (fx - fy);
    double bVal = 200 * (fy - fz);

    // This now correctly returns the top-level LabColor class.
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

  // ---------------- CORRECTED TAP COORDINATE MAPPING ----------------
  // This logic is crucial for accurate color picking when BoxFit.contain is used.
  Offset _mapTapToImage(
    Size widgetSize,
    int imageWidth,
    int imageHeight,
    Offset tap,
  ) {
    // 1. Calculate the aspect ratios
    final imageRatio = imageWidth / imageHeight;
    final widgetRatio = widgetSize.width / widgetSize.height;

    double renderedWidth;
    double renderedHeight;
    double offsetX; // Horizontal offset (letterbox padding)
    double offsetY; // Vertical offset (letterbox padding)

    if (imageRatio > widgetRatio) {
      // Image is wider than the widget (constrained by width) -> Letterboxing on top/bottom
      renderedWidth = widgetSize.width;
      renderedHeight = widgetSize.width / imageRatio;
      offsetX = 0;
      offsetY = (widgetSize.height - renderedHeight) / 2;
    } else {
      // Image is taller than the widget (constrained by height) -> Letterboxing on left/right
      renderedHeight = widgetSize.height;
      renderedWidth = widgetSize.height * imageRatio;
      offsetX = (widgetSize.width - renderedWidth) / 2;
      offsetY = 0;
    }

    // 2. Check if the tap is outside the rendered image area (on the letterbox)
    if (tap.dx < offsetX ||
        tap.dx > offsetX + renderedWidth ||
        tap.dy < offsetY ||
        tap.dy > offsetY + renderedHeight) {
      // Return an invalid/clamped position if tapped on the empty space
      // Returning (-1, -1) signals the tap handler to ignore the tap.
      return const Offset(-1, -1);
    }

    // 3. Map the tap coordinates to the image pixel coordinates
    // Calculate the coordinate relative to the top-left of the rendered image
    final relativeX = tap.dx - offsetX;
    final relativeY = tap.dy - offsetY;

    // Scale the relative coordinate to the full image size
    final imageX = (relativeX * (imageWidth / renderedWidth))
        .clamp(0, imageWidth - 1)
        .toDouble();
    final imageY = (relativeY * (imageHeight / renderedHeight))
        .clamp(0, imageHeight - 1)
        .toDouble();

    return Offset(imageX, imageY);
  }

  // ---------------- GET COLOR FAMILY ----------------
  String _getColorFamily(int r, int g, int b) {
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final diff = max - min;
    final lightness = (max + min) / 2 / 255;
    final saturation = diff == 0
        ? 0.0
        : diff / (255 - (2 * lightness * 255 - 255).abs());

    if (saturation < 0.15) {
      if (lightness < 0.2) return "Black";
      if (lightness > 0.8) return "White";
      return "Gray";
    }

    double hue = 0;
    if (diff != 0) {
      if (max == r) {
        hue = 60 * (((g - b) / diff) % 6);
      } else if (max == g) {
        hue = 60 * (((b - r) / diff) + 2);
      } else {
        hue = 60 * (((r - g) / diff) + 4);
      }
    }
    if (hue < 0) hue += 360;

    if (hue < 15 || hue >= 345) return "Red";
    if (hue < 45) return "Orange";
    if (hue < 75) return "Yellow";
    if (hue < 150) return "Green";
    if (hue < 210) return "Cyan";
    if (hue < 270) return "Blue";
    if (hue < 330) return "Purple";
    return "Pink";
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

        // 🔑 Using deltaE for accurate spot detection
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

  // ---------------- RECOLOR FILTER ----------------
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
    final hueDiff = targetHSV.hue - sourceHSV.hue;

    // Calculate saturation and value scaling factors relative to the source color
    final satScale =
        targetHSV.saturation /
        (sourceHSV.saturation == 0 ? 1 : sourceHSV.saturation);
    final valScale =
        targetHSV.value / (sourceHSV.value == 0 ? 1 : sourceHSV.value);

    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final pixel = result.getPixelSafe(x, y);
        final currentColor = Color.fromARGB(
          255,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );

        // 🔑 Using deltaE for accurate recolor selection
        if (deltaE(currentColor, sourceColor) < _colorTolerance) {
          final hsv = HSVColor.fromColor(currentColor);
          final newHue = (hsv.hue + hueDiff) % 360;

          // Apply scaling to maintain relative saturation/value
          final newSaturation = (hsv.saturation * satScale).clamp(0.0, 1.0);
          final newValue = (hsv.value * valScale).clamp(0.0, 1.0);

          final newColor = HSVColor.fromAHSV(
            1.0,
            newHue,
            newSaturation,
            newValue,
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

  // ---------------- TAP HANDLER (UPDATED) ----------------
  void _handleTap(TapDownDetails details) {
    if (_originalImage == null) return;

    final renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final widgetSize = renderBox.size;

    final mapped = _mapTapToImage(
      widgetSize,
      _originalImage!.width,
      _originalImage!.height,
      details.localPosition,
    );

    // 🛑 NEW CHECK: If tap is on the letterbox padding, mapped will be (-1, -1). Ignore the tap.
    if (mapped.dx == -1 && mapped.dy == -1) {
      return;
    }

    // Use the correctly mapped pixel coordinates
    final pickedColor = _weightedAveragePixels(
      _originalImage!,
      mapped.dx.round(),
      mapped.dy.round(),
    );

    setState(() {
      _tapPosition = details.localPosition;
      _pickedColor = pickedColor;
      _colorName = ColorNames.guess(_pickedColor);
      _r = _pickedColor.red;
      _g = _pickedColor.green;
      _b = _pickedColor.blue;
      _colorFamily = _getColorFamily(_r, _g, _b);

      if (_currentFilterMode == FilterMode.spot) {
        _spotColors.add(pickedColor);
        // Apply filter immediately after picking
        _displayImage = _applySpotFilter(
          _baseImageForCurrentMode!,
          _spotColors,
        );
      } else if (_currentFilterMode == FilterMode.recolor) {
        _recolorTapPosition = details.localPosition;
        final hsv = HSVColor.fromColor(pickedColor);
        // Set target color to the exact hue of the picked color,
        // but at full saturation/value for the slider visualization
        _recolorTargetColor = HSVColor.fromAHSV(
          1.0,
          hsv.hue,
          1.0,
          1.0,
        ).toColor();
        // Apply the recolor filter with the initial settings
        _applyRecolorFilter(_recolorTargetColor);
      }
    });
  }

  // ---------------- UI & SAVE HANDLERS ----------------
  void _switchFilterMode(FilterMode mode) {
    setState(() {
      _currentFilterMode = mode;
      // Reset states when switching modes
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
          // Return the path of the filtered image
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
                GestureDetector(
                  onTapDown: _handleTap,
                  child: Center(
                    child: Image.memory(
                      // IMPORTANT: Used encodePng for display to fix black screen issues
                      // (assuming this was the underlying problem)
                      img.encodePng(_displayImage!),
                      key: _imageKey,
                      fit: BoxFit
                          .contain, // This requires the complex mapping logic
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
                        // Save Button
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
                        // Done Button (Replaces Freeze)
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
                // Tap marker
                if (_tapPosition != null)
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
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
                        // Color slider (recolor mode only)
                        if (_currentFilterMode == FilterMode.recolor) ...[
                          _buildColorSlider(),
                          const SizedBox(height: 16),
                        ],
                        // Instruction text
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
                        // Mode selector
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
