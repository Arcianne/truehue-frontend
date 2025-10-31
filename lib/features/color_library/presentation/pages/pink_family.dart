import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinkFamilyPage extends StatelessWidget {
  const PinkFamilyPage({super.key});

  // Pink family colors from KNN algorithm
  static const Map<String, List<int>> pinkColors = {
    'Pink': [255, 192, 203],
    'Light Pink': [255, 182, 193],
    'Pale Pink': [250, 218, 221],
    'Soft Pink': [255, 200, 220],
    'Pastel Pink': [255, 209, 220],
    'Cotton Candy': [255, 188, 217],
    'Bubblegum': [255, 193, 204],
    'Candy Pink': [228, 113, 122],
    'Sweet Pink': [253, 215, 228],
    'Hot Pink': [255, 105, 180],
    'Deep Pink': [255, 20, 147],
    'Bright Pink': [255, 0, 127],
    'Shocking Pink': [252, 15, 192],
    'Neon Pink': [255, 16, 240],
    'Magenta': [255, 0, 255],
    'Deep Magenta': [204, 0, 204],
    'Dark Magenta': [139, 0, 139],
    'Persian Pink': [247, 127, 190],
    'Violet Pink': [251, 95, 253],
    'Orchid Pink': [242, 189, 205],
    'Lavender Pink': [251, 174, 210],
    'Carnation Pink': [255, 166, 201],
    'Ballet Pink': [244, 140, 186],
    'Ballet Slipper': [238, 207, 217],
    'Flamingo': [252, 142, 172],
    'Salmon Pink': [255, 145, 164],
    'Peach Pink': [255, 218, 185],
    'Apricot Pink': [251, 206, 177],
    'Blush Pink': [254, 206, 215],
    'Dusty Pink': [220, 177, 172],
    'Mauve Pink': [224, 176, 255],
    'Lilac Pink': [200, 162, 200],
    'Thistle Pink': [216, 191, 216],
    'Peony': [250, 193, 209],
    'Cherry Blossom': [255, 183, 197],
    'Sakura': [255, 223, 231],
    'Azalea': [247, 200, 220],
    'Begonia': [255, 106, 106],
    'Hibiscus': [182, 49, 108],
    'Hollyhock': [225, 180, 192],
    'Impatiens': [255, 173, 185],
    'Princess Pink': [255, 213, 220],
    'Fairy Pink': [238, 192, 210],
    'French Pink': [253, 108, 158],
    'Persian Rose': [254, 40, 162],
    'Shell Pink': [255, 200, 200],
    'Shrimp Pink': [255, 94, 133],
    'Strawberry Pink': [255, 67, 164],
    'Raspberry Pink': [227, 11, 92],
    'Cranberry Pink': [159, 43, 104],
    'Cherry Pink': [222, 49, 99],
    'Wine Pink': [145, 95, 109],
    'Magenta Pink': [204, 51, 139],
    'Tulip': [255, 135, 141],
    'French Rose': [246, 74, 138],
    'English Rose': [254, 176, 173],
    'Desert Rose': [193, 72, 105],
    'Alpine Rose': [222, 120, 140],
    'India Pink': [205, 145, 158],
    'Japan Pink': [255, 181, 197],
    'Tickle Me Pink': [252, 137, 172],
    'Piggy Pink': [253, 221, 230],
    'Barbie Pink': [224, 33, 138],
    'Romance': [255, 207, 210],
    'Sweetie': [255, 198, 209],
    'Pink Lemonade': [255, 117, 140],
    'Pink Grapefruit': [255, 105, 97],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Pink Family',
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
        itemCount: pinkColors.length,
        itemBuilder: (context, index) {
          final colorName = pinkColors.keys.elementAt(index);
          final rgb = pinkColors[colorName]!;
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
