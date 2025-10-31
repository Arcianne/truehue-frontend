import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YellowFamilyPage extends StatelessWidget {
  const YellowFamilyPage({super.key});

  // Yellow family colors from KNN algorithm
  static const Map<String, List<int>> yellowColors = {
    'Yellow': [255, 255, 0],
    'Pure Yellow': [255, 237, 0],
    'True Yellow': [255, 238, 0],
    'Vivid Yellow': [255, 227, 0],
    'Neon Yellow': [207, 255, 4],
    'Fluorescent Yellow': [204, 255, 0],
    'Lemon': [255, 247, 0],
    'Lemon Yellow': [255, 244, 79],
    'Citron': [159, 169, 31],
    'Lime Yellow': [227, 255, 0],
    'Chartreuse': [127, 255, 0],
    'Light Yellow': [255, 255, 224],
    'Pale Yellow': [255, 255, 175],
    'Soft Yellow': [255, 253, 208],
    'Pastel Yellow': [253, 253, 150],
    'Butter': [255, 228, 132],
    'Butter Yellow': [255, 241, 181],
    'Cream': [255, 253, 208],
    'Cream Yellow': [255, 243, 179],
    'Vanilla': [243, 229, 171],
    'Custard': [255, 253, 208],
    'Banana': [255, 225, 53],
    'Banana Yellow': [254, 251, 210],
    'Canary': [255, 239, 0],
    'Canary Yellow': [255, 255, 153],
    'Sunny': [242, 234, 0],
    'Sunflower': [255, 218, 3],
    'Dandelion': [240, 225, 48],
    'Buttercup': [254, 221, 96],
    'Daffodil': [255, 255, 49],
    'Primrose': [237, 220, 92],
    'Goldenrod': [218, 165, 32],
    'Light Goldenrod': [250, 250, 210],
    'Pale Goldenrod': [238, 232, 170],
    'Gold': [255, 215, 0],
    'Golden Yellow': [255, 223, 0],
    'Metallic Gold': [212, 175, 55],
    'Vegas Gold': [197, 179, 88],
    'Old Gold': [207, 181, 59],
    'Antique Gold': [172, 138, 62],
    'Harvest Gold': [218, 145, 0],
    'School Bus Yellow': [255, 216, 0],
    'Taxi Cab Yellow': [244, 214, 53],
    'Corn': [251, 236, 93],
    'Corn Yellow': [245, 222, 179],
    'Cornsilk': [255, 248, 220],
    'Maize': [251, 236, 93],
    'Wheat': [245, 222, 179],
    'Straw': [228, 217, 111],
    'Hay': [221, 178, 84],
    'Blonde': [250, 240, 190],
    'Flax': [238, 220, 130],
    'Champagne': [247, 231, 206],
    'Khaki': [240, 230, 140],
    'Sand': [194, 178, 128],
    'Desert Sand': [237, 201, 175],
    'Ecru': [194, 178, 128],
    'Beige': [245, 245, 220],
    'Tan': [210, 180, 140],
    'Buff': [240, 220, 130],
    'Biscuit': [255, 228, 196],
    'Honeycomb': [255, 242, 99],
    'Mustard': [255, 219, 88],
    'Dijon': [196, 141, 0],
    'Ochre': [204, 119, 34],
    'Yellow Ochre': [227, 163, 63],
    'Brass': [181, 166, 66],
    'Saffron': [244, 196, 48],
    'Turmeric': [254, 172, 15],
    'Pineapple': [255, 226, 44],
    'Lemon Chiffon': [255, 250, 205],
    'Lemon Meringue': [246, 234, 190],
    'Lemon Cream': [255, 244, 206],
    'Citrine': [228, 208, 10],
    'Lemonade': [255, 252, 127],
    'Daisy': [255, 240, 79],
    'Jasmine': [248, 222, 126],
    'Jonquil': [250, 218, 94],
    'Mimosa': [248, 228, 179],
    'Acacia': [227, 208, 87],
    'Topaz': [255, 200, 124],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Yellow Family',
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
        itemCount: yellowColors.length,
        itemBuilder: (context, index) {
          final colorName = yellowColors.keys.elementAt(index);
          final rgb = yellowColors[colorName]!;
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
