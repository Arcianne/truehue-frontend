import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrownFamilyPage extends StatelessWidget {
  const BrownFamilyPage({super.key});

  // Brown family colors from KNN algorithm
  static const Map<String, List<int>> brownColors = {
    'Brown': [165, 42, 42],
    'Dark Brown': [101, 67, 33],
    'Deep Brown': [74, 44, 42],
    'Light Brown': [181, 101, 29],
    'Pale Brown': [152, 118, 84],
    'Saddle Brown': [139, 69, 19],
    'Medium Brown': [128, 70, 27],
    'Dark Chestnut': [149, 69, 53],
    'Light Chestnut': [205, 133, 63],
    'Dark Mahogany': [82, 23, 0],
    'Red Mahogany': [110, 25, 18],
    'Russet': [128, 70, 27],
    'Copper Brown': [150, 90, 62],
    'Bronze Brown': [128, 86, 35],
    'Sienna': [160, 82, 45],
    'Burnt Sienna': [233, 116, 81],
    'Raw Sienna': [214, 138, 89],
    'Umber': [99, 81, 71],
    'Burnt Umber': [138, 51, 36],
    'Raw Umber': [130, 102, 68],
    'Chocolate': [210, 105, 30],
    'Dark Chocolate': [77, 40, 0],
    'Milk Chocolate': [129, 70, 11],
    'Hot Chocolate': [100, 65, 23],
    'Cocoa': [135, 95, 66],
    'Cocoa Brown': [55, 31, 17],
    'Coffee': [111, 78, 55],
    'Coffee Bean': [44, 22, 8],
    'Espresso': [74, 44, 42],
    'Mocha': [135, 84, 60],
    'Cappuccino': [162, 107, 78],
    'Latte': [196, 142, 103],
    'Dark Caramel': [175, 111, 54],
    'Fudge': [95, 56, 38],
    'Peanut': [120, 72, 0],
    'Peanut Butter': [193, 154, 107],
    'Almond': [239, 222, 205],
    'Hazelnut': [142, 118, 86],
    'Walnut': [92, 64, 51],
    'Pecan': [158, 91, 64],
    'Chestnut Brown': [152, 105, 96],
    'Acorn': [135, 79, 57],
    'Oak': [128, 84, 32],
    'Wood': [193, 154, 107],
    'Driftwood': [175, 141, 120],
    'Cedar': [125, 84, 72],
    'Pine Wood': [229, 217, 182],
    'Cherry Wood': [116, 41, 33],
    'Maple Wood': [210, 180, 140],
    'Bamboo': [218, 178, 115],
    'Teak': [184, 138, 84],
    'Ash Wood': [178, 153, 126],
    'Birch': [241, 230, 214],
    'Hickory': [180, 130, 80],
    'Sandalwood': [204, 158, 108],
    'Nutmeg': [129, 70, 31],
    'Clove': [165, 94, 51],
    'Ginger': [176, 101, 0],
    'Allspice': [128, 70, 27],
    'Cardamom': [157, 129, 97],
    'Cumin': [146, 111, 91],
    'Paprika': [141, 53, 24],
    'Tobacco': [113, 93, 65],
    'Cigar': [130, 90, 44],
    'Leather': [150, 90, 62],
    'Light Tan': [255, 228, 196],
    'Dark Tan': [145, 129, 81],
    'Sandy Brown': [244, 164, 96],
    'Dune': [220, 187, 153],
    'Sahara': [188, 152, 126],
    'Dark Khaki': [189, 183, 107],
    'Taupe': [72, 60, 50],
    'Stone': [140, 140, 140],
    'Clay': [204, 119, 34],
    'Terra Cotta Brown': [226, 114, 91],
    'Terracotta Brown': [204, 78, 92],
    'Sandstone': [208, 192, 179],
    'Limestone': [232, 221, 203],
    'Sepia Brown': [112, 66, 20],
    'Marigold Brown': [234, 162, 33],
    'Curry Brown': [206, 144, 49],
    'Blonde Wood': [210, 180, 140],
    'Autumn Brown': [205, 133, 63],
    'Harvest Brown': [255, 155, 66],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Brown Family',
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
        itemCount: brownColors.length,
        itemBuilder: (context, index) {
          final colorName = brownColors.keys.elementAt(index);
          final rgb = brownColors[colorName]!;
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
