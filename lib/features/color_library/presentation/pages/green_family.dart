import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GreenFamilyPage extends StatelessWidget {
  const GreenFamilyPage({super.key});

  // Green family colors from KNN algorithm
  static const Map<String, List<int>> greenColors = {
'Dark Green': [0, 100, 0],
    'Deep Green': [5, 102, 8],
    'Forest Green': [34, 139, 34],
    'Hunter Green': [53, 94, 59],
    'Pine Green': [1, 121, 111],
    'Evergreen': [5, 71, 42],
    'Green': [0, 128, 0],
    'True Green': [0, 153, 0],
    'Pure Green': [0, 168, 0],
    'Bright Green': [102, 255, 0],
    'Vivid Green': [0, 255, 0],
    'Neon Green': [57, 255, 20],
    'Fluorescent Green': [8, 255, 8],
    'Lime Green': [50, 205, 50],
    'Light Green': [144, 238, 144],
    'Pale Green': [152, 251, 152],
    'Pastel Green': [119, 221, 119],
    'Mint': [189, 252, 201],
    'Mint Green': [152, 255, 152],
    'Mint Cream': [245, 255, 250],
    'Spearmint': [69, 139, 116],
    'Peppermint': [193, 255, 202],
    'Wintergreen': [62, 180, 137],
    'Spring Green': [0, 255, 127],
    'Medium Spring Green': [0, 250, 154],
    'Yellow Green': [154, 205, 50],
    'Lawn Green': [124, 252, 0],
    'Grass Green': [63, 155, 11],
    'Kelly Green': [76, 187, 23],
    'Shamrock': [69, 206, 162],
    'Clover': [0, 132, 61],
    'Irish Green': [0, 158, 96],
    'Lucky Green': [43, 127, 58],
    'Emerald': [80, 200, 120],
    'Jade': [0, 168, 107],
    'Malachite': [11, 218, 81],
    'Viridian': [64, 130, 109],
    'Teal': [0, 128, 128],
    'Dark Teal': [0, 77, 77],
    'Turquoise': [64, 224, 208],
    'Medium Turquoise': [72, 209, 204],
    'Dark Turquoise': [0, 206, 209],
    'Sea Green': [46, 139, 87],
    'Medium Sea Green': [60, 179, 113],
    'Light Sea Green': [32, 178, 170],
    'Ocean Green': [72, 191, 145],
    'Seafoam': [159, 226, 191],
    'Seafoam Green': [147, 223, 184],
    'Aquamarine': [127, 255, 212],
    'Medium Aquamarine': [102, 221, 170],
    'Caribbean': [0, 204, 153],
    'Tropical': [0, 181, 173],
    'Lagoon': [4, 169, 173],
    'Olive': [128, 128, 0],
    'Olive Green': [186, 184, 108],
    'Olive Drab': [107, 142, 35],
    'Dark Olive': [85, 107, 47],
    'Army Green': [75, 83, 32],
    'Military Green': [102, 102, 0],
    'Camouflage': [120, 134, 107],
    'Sage': [188, 184, 138],
    'Sage Green': [157, 172, 144],
    'Fern': [113, 188, 120],
    'Fern Green': [79, 121, 66],
    'Moss': [138, 154, 91],
    'Moss Green': [173, 223, 173],
    'Lichen': [129, 140, 67],
    'Algae': [84, 172, 104],
    'Seaweed': [23, 116, 66],
    'Kale': [83, 105, 66],
    'Thyme': [152, 163, 145],
    'Oregano': [124, 134, 72],
    'Parsley': [28, 123, 11],
    'Cilantro': [142, 177, 117],
    'Avocado': [86, 130, 3],
    'Pear': [209, 226, 49],
    'Apple Green': [141, 182, 0],
    'Granny Smith': [168, 228, 160],
    'Lime Peel': [191, 255, 0],
    'Pistachio': [147, 197, 114],
    'Honeydew': [240, 255, 240],
    'Cucumber': [124, 176, 135],
    'Celery': [184, 202, 135],
    'Lettuce': [202, 237, 154],
    'Spinach': [35, 111, 43],
    'Artichoke': [139, 157, 115],
    'Asparagus': [135, 169, 107],
    'Green Pea': [166, 209, 137],
    'Split Pea': [144, 168, 65],
    'Green Bean': [108, 140, 69],
    'Pickle': [117, 142, 41],
    'Green Tea': [214, 232, 167],
    'Matcha': [136, 176, 75],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Green Family',
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
        itemCount: greenColors.length,
        itemBuilder: (context, index) {
          final colorName = greenColors.keys.elementAt(index);
          final rgb = greenColors[colorName]!;
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
                    color: Colors.white.withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.5),
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
