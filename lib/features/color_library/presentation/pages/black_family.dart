import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlackFamilyPage extends StatelessWidget {
  const BlackFamilyPage({super.key});

  // Black family colors from KNN algorithm
  static const Map<String, List<int>> blackColors = {
        'Black': [0, 0, 0],
    'Jet Black': [10, 10, 10],
    'Tar': [13, 13, 13],
    'Coal': [16, 16, 16],
    'Midnight Black': [15, 15, 15],
    'Ebony': [21, 19, 18],
    'Lead': [33, 34, 38],
    'Dark Charcoal': [36, 36, 36],
    'Thunder': [51, 51, 51],
    'Charcoal': [54, 69, 79],
    'Gunmetal': [42, 52, 57],
    'Graphite': [65, 74, 76],
    'Iron': [77, 77, 82],
    'Shadow': [32, 32, 32],
    'Dark Shadow': [20, 20, 20],
    'Raven': [66, 66, 66],
    'Jet': [52, 52, 52],
    'Onyx': [53, 56, 57],
    'Obsidian': [59, 72, 81],
    'Midnight': [25, 25, 112],
    'Licorice': [26, 17, 16],
    'Ink': [28, 28, 28],
    'Asphalt': [19, 19, 19],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Black Family',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blackColors.length,
        itemBuilder: (context, index) {
          final colorName = blackColors.keys.elementAt(index);
          final rgb = blackColors[colorName]!;
          return _buildColorItem(context, colorName, rgb);
        },
      ),
    );
  }

  Widget _buildColorItem(
    BuildContext context,
    String colorName,
    List<int> rgb,
  ) {
    final color = Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1570),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ColorDetailPage(colorName: colorName, rgb: rgb),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Color preview circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
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
                      colorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RGB(${rgb[0]}, ${rgb[1]}, ${rgb[2]})',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// Color Detail Page (like Tangerine example in image 2)
class ColorDetailPage extends StatelessWidget {
  final String colorName;
  final List<int> rgb;

  const ColorDetailPage({
    super.key,
    required this.colorName,
    required this.rgb,
  });

  String _rgbToHex(List<int> rgb) {
    return '#${rgb[0].toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${rgb[1].toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${rgb[2].toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  Map<String, int> _rgbToCMYK(List<int> rgb) {
    final r = rgb[0] / 255;
    final g = rgb[1] / 255;
    final b = rgb[2] / 255;

    final k = 1 - [r, g, b].reduce((a, b) => a > b ? a : b);
    if (k == 1) {
      return {'c': 0, 'm': 0, 'y': 0, 'k': 100};
    }

    final c = ((1 - r - k) / (1 - k) * 100).round();
    final m = ((1 - g - k) / (1 - k) * 100).round();
    final y = ((1 - b - k) / (1 - k) * 100).round();
    final kValue = (k * 100).round();

    return {'c': c, 'm': m, 'y': y, 'k': kValue};
  }

  Map<String, int> _rgbToHSB(List<int> rgb) {
    final r = rgb[0] / 255;
    final g = rgb[1] / 255;
    final b = rgb[2] / 255;

    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final diff = max - min;

    // Hue
    double h = 0;
    if (diff != 0) {
      if (max == r) {
        h = 60 * (((g - b) / diff) % 6);
      } else if (max == g) {
        h = 60 * (((b - r) / diff) + 2);
      } else {
        h = 60 * (((r - g) / diff) + 4);
      }
    }
    if (h < 0) h += 360;

    // Saturation
    final s = max == 0 ? 0 : (diff / max * 100);

    // Brightness
    final brightness = max * 100;

    return {'h': h.round(), 's': s.round(), 'b': brightness.round()};
  }

  @override
  Widget build(BuildContext context) {
    final color = Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1.0);
    final hex = _rgbToHex(rgb);
    final cmyk = _rgbToCMYK(rgb);
    final hsb = _rgbToHSB(rgb);

    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.arrow_back, color: Colors.transparent),
            const SizedBox(width: 8),
            const Text(
              'Color Library',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            Text(
              colorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Large color preview
          Expanded(
            flex: 2,
            child: Container(width: double.infinity, color: color),
          ),

          // Color information section
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF130E64),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildColorInfo('RGB', '${rgb[0]}, ${rgb[1]}, ${rgb[2]}'),
                  const SizedBox(height: 16),
                  _buildColorInfo(
                    'CMYK',
                    '${cmyk['c']}, ${cmyk['m']}, ${cmyk['y']}, ${cmyk['k']}',
                  ),
                  const SizedBox(height: 16),
                  _buildColorInfo(
                    'HSB',
                    '${hsb['h']}, ${hsb['s']}, ${hsb['b']}',
                  ),
                  const SizedBox(height: 16),
                  _buildColorInfo('HEX', hex),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18)),
      ],
    );
  }
}
