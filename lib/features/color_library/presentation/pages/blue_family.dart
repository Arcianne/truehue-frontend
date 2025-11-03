import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlueFamilyPage extends StatelessWidget {
  const BlueFamilyPage({super.key});

  // Blue family colors from KNN algorithm
  static const Map<String, List<int>> blueColors = {
    'Navy': [0, 0, 128],
    'Dark Navy': [0, 0, 80],
    'Midnight Blue': [25, 25, 112],
    'Dark Blue': [0, 0, 139],
    'Deep Blue': [0, 0, 150],
    'Prussian Blue': [0, 49, 83],
    'Space Blue': [29, 41, 81],
    'Galaxy': [42, 82, 190],
    'Cosmos': [50, 74, 178],
    'Sapphire': [15, 82, 186],
    'Lapis': [38, 97, 156],
    'Cobalt': [0, 71, 171],
    'Royal Blue': [65, 105, 225],
    'Imperial Blue': [0, 35, 149],
    'Persian Blue': [28, 57, 187],
    'Egyptian Blue': [16, 52, 166],
    'Cerulean': [0, 123, 167],
    'Azure': [0, 127, 255],
    'Blue': [0, 0, 255],
    'True Blue': [0, 115, 207],
    'Bright Blue': [0, 135, 255],
    'Vivid Blue': [0, 51, 255],
    'Electric Blue': [125, 249, 255],
    'Neon Blue': [77, 77, 255],
    'Sky Blue': [135, 206, 235],
    'Light Sky Blue': [135, 206, 250],
    'Deep Sky Blue': [0, 191, 255],
    'Powder Blue': [176, 224, 230],
    'Baby Blue': [137, 207, 240],
    'Pastel Blue': [174, 198, 207],
    'Pale Blue': [175, 238, 238],
    'Light Blue': [173, 216, 230],
    'Ice Blue': [175, 238, 238],
    'Glacier': [128, 191, 255],
    'Arctic': [130, 195, 228],
    'Frost': [221, 244, 248],
    'Steel Blue': [70, 130, 180],
    'Slate Blue': [106, 90, 205],
    'Cadet Blue': [95, 158, 160],
    'Denim': [21, 96, 189],
    'Jeans': [93, 173, 236],
    'Chambray': [137, 157, 192],
    'Indigo': [75, 0, 130],
    'Periwinkle': [204, 204, 255],
    'Cornflower': [100, 149, 237],
    'Bluebell': [162, 162, 208],
    'Hyacinth': [202, 174, 224],
    'Iris': [90, 79, 207],
    'Dodger Blue': [30, 144, 255],
    'Carolina Blue': [153, 186, 221],
    'Columbia Blue': [155, 221, 255],
    'Yale Blue': [15, 77, 146],
    'Oxford Blue': [0, 33, 71],
    'Cambridge Blue': [163, 193, 173],
    'Alice Blue': [240, 248, 255],
    'Ocean': [0, 119, 190],
    'Ocean Blue': [79, 66, 181],
    'Sea Blue': [0, 105, 148],
    'Marine': [0, 78, 137],
    'Marine Blue': [1, 70, 127],
    'Sailor Blue': [0, 103, 165],
    'Nautical': [0, 102, 204],
    'Captain': [0, 77, 128],
    'Admiral': [0, 56, 101],
    'Caribbean Blue': [0, 204, 153],
    'Tropical Blue': [0, 181, 236],
    'Pool Blue': [0, 174, 239],
    'Bright Cyan': [65, 244, 252],
    'Light Cyan': [224, 255, 255],
    'Bright Turquoise': [8, 232, 222],
    'Teal Blue': [54, 117, 136],
    'Peacock': [51, 161, 201],
    'Robin Egg': [0, 204, 204],
    'Robin Egg Blue': [31, 206, 203],
    'Bluebird': [65, 105, 225],
    'Blue Jay': [42, 118, 198],
    'Dolphin': [97, 134, 155],
    'Whale': [54, 70, 93],
    'Bondi Blue': [0, 149, 182],
    'Aegean': [71, 139, 166],
    'Mediterranean': [59, 132, 163],
    'Adriatic': [44, 150, 199],
    'Baltic': [51, 113, 151],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Blue Family',
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
        itemCount: blueColors.length,
        itemBuilder: (context, index) {
          final colorName = blueColors.keys.elementAt(index);
          final rgb = blueColors[colorName]!;
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
