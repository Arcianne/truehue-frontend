import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PurpleFamilyPage extends StatelessWidget {
  const PurpleFamilyPage({super.key});

  // Purple family colors from KNN algorithm
  static const Map<String, List<int>> purpleColors = {
    'Dark Purple': [48, 25, 52],
    'Deep Purple': [58, 12, 163],
    'Purple': [128, 0, 128],
    'True Purple': [102, 0, 153],
    'Bright Purple': [191, 64, 191],
    'Vivid Purple': [159, 0, 255],
    'Neon Purple': [189, 51, 255],
    'Electric Purple': [191, 0, 255],
    'Royal Purple': [120, 81, 169],
    'Imperial Purple': [102, 2, 60],
    'Byzantine': [189, 51, 164],
    'Violet': [238, 130, 238],
    'Dark Violet': [148, 0, 211],
    'Blue Violet': [138, 43, 226],
    'Medium Violet': [147, 112, 219],
    'Red Violet': [199, 21, 133],
    'Violet Red': [208, 32, 144],
    'Bright Magenta': [255, 0, 255],
    'Hot Magenta Purple': [255, 29, 206],
    'Indigo Purple': [65, 0, 120],
    'Plum': [221, 160, 221],
    'Dark Plum': [63, 1, 44],
    'Sugar Plum': [145, 78, 117],
    'Eggplant': [97, 64, 81],
    'Aubergine': [59, 9, 39],
    'Grape': [111, 45, 168],
    'Concord': [82, 42, 119],
    'Wine Purple': [85, 37, 130],
    'Mulberry': [197, 75, 140],
    'Berry Purple': [102, 0, 102],
    'Lavender': [230, 230, 250],
    'Light Lavender': [244, 222, 255],
    'Dark Lavender': [115, 79, 150],
    'Medium Lavender': [199, 177, 229],
    'Pale Lavender': [220, 208, 255],
    'Lilac': [200, 162, 200],
    'Light Lilac': [229, 204, 255],
    'Dark Lilac': [153, 102, 204],
    'Mauve': [224, 176, 255],
    'Light Mauve': [240, 209, 255],
    'Dark Mauve': [153, 51, 102],
    'Orchid': [218, 112, 214],
    'Dark Orchid': [153, 50, 204],
    'Medium Orchid': [186, 85, 211],
    'Light Orchid': [230, 168, 215],
    'Thistle': [216, 191, 216],
    'Heather': [174, 148, 184],
    'Wisteria': [201, 160, 220],
    'Amethyst': [153, 102, 204],
    'Light Amethyst': [197, 166, 255],
    'Dark Amethyst': [103, 65, 136],
    'Crocus': [143, 110, 181],
    'Petunia': [175, 101, 163],
    'Pansy': [120, 24, 74],
    'Violet Flower': [139, 95, 191],
    'Clematis': [136, 82, 127],
    'Verbena': [120, 24, 74],
    'Aster': [155, 89, 182],
    'Lupine': [138, 109, 167],
    'Bellflower': [158, 102, 171],
    'Anemone': [157, 129, 186],
    'Purple Haze': [163, 134, 175],
    'Purple Rain': [113, 88, 143],
    'Purple Heart': [105, 53, 156],
    'Purple Mountain': [150, 123, 182],
    'Purple Passion': [74, 0, 95],
    'Purple Prince': [99, 29, 210],
    'Purple Pizzazz': [254, 78, 218],
    'Razzle Dazzle': [153, 0, 153],
    'Byzantine Purple': [112, 41, 99],
    'French Lilac': [134, 96, 142],
    'English Violet': [86, 60, 92],
    'Parma': [153, 102, 204],
    'Venetian Purple': [145, 95, 109],
    'Pompadour': [106, 58, 81],
    'Phlox': [223, 0, 255],
    'Mystic': [209, 159, 232],
    'Cosmic': [136, 49, 121],
    'Galaxy Purple': [135, 78, 162],
    'Space Purple': [70, 48, 94],
    'Twilight': [138, 73, 107],
    'Dusk Purple': [94, 53, 80],
    'Evening': [104, 79, 124],
    'Midnight Purple': [40, 26, 56],
    'Dream': [153, 102, 204],
    'Fantasy': [176, 104, 161],
    'Enchanted': [162, 107, 186],
    'Magic': [180, 96, 200],
    'Wizard': [126, 50, 176],
    'Sorcerer': [85, 37, 130],
    'Mystic Purple': [167, 107, 207],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Purple Family',
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
        itemCount: purpleColors.length,
        itemBuilder: (context, index) {
          final colorName = purpleColors.keys.elementAt(index);
          final rgb = purpleColors[colorName]!;
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
