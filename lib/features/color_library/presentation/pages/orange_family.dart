import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrangeFamilyPage extends StatelessWidget {
  const OrangeFamilyPage({super.key});

  // Orange family colors from KNN algorithm
  static const Map<String, List<int>> orangeColors = {
'Dark Orange': [255, 140, 0],
    'Dark Salmon': [233, 150, 122],
    'Deep Orange': [255, 87, 51],
    'Burnt Orange': [204, 85, 0],
    'Orange': [255, 165, 0],
    'Bright Orange': [255, 123, 0],
    'True Orange': [255, 153, 0],
    'Vivid Orange': [255, 95, 31],
    'Electric Orange': [255, 63, 52],
    'Safety Orange': [255, 103, 0],
    'International Orange': [255, 79, 0],
    'Hunter Orange': [255, 93, 0],
    'Construction Orange': [248, 76, 30],
    'Fire Orange': [255, 69, 0],
    'Flame Orange': [226, 88, 34],
    'Cherry Tomato': [254, 54, 63],
    'Coral': [255, 127, 80],
    'Salmon': [250, 128, 114],
    'Salmon Orange': [255, 140, 105],
    'Peach': [255, 218, 185],
    'Peach Orange': [255, 204, 153],
    'Apricot': [251, 206, 177],
    'Apricot Orange': [255, 175, 100],
    'Tangerine': [242, 133, 0],
    'Mandarin': [243, 134, 48],
    'Clementine': [255, 140, 56],
    'Satsuma': [255, 143, 0],
    'Citrus': [255, 152, 0],
    'Orange Peel': [255, 159, 0],
    'Mango': [255, 130, 67],
    'Papaya': [255, 239, 213],
    'Cantaloupe': [255, 175, 115],
    'Melon': [253, 188, 180],
    'Pumpkin': [255, 117, 24],
    'Squash': [242, 140, 40],
    'Carrot': [237, 145, 33],
    'Sweet Potato': [250, 152, 120],
    'Yam': [212, 136, 82],
    'Persimmon': [236, 88, 0],
    'Kumquat': [255, 156, 46],
    'Nectarine': [255, 168, 88],
    'Amber': [255, 191, 0],
    'Honey': [235, 174, 52],
    'Golden Orange': [255, 177, 31],
    'Butterscotch': [224, 167, 65],
    'Caramel': [255, 213, 154],
    'Toffee': [178, 132, 90],
    'Cognac': [159, 56, 0],
    'Brandy': [135, 65, 0],
    'Whiskey': [214, 137, 16],
    'Bourbon': [184, 109, 41],
    'Rust': [183, 65, 14],
    'Copper': [184, 115, 51],
    'Bronze': [205, 127, 50],
    'Penny': [163, 111, 94],
    'Cayenne': [237, 28, 36],
    'Chili': [226, 61, 40],
    'Tiger': [253, 106, 2],
    'Lion': [193, 154, 107],
    'Fox': [196, 78, 0],
    'Autumn': [205, 133, 63],
    'Fall': [234, 126, 93],
    'Harvest': [255, 155, 66],
    'Sunset': [250, 214, 165],
    'Sunrise': [255, 191, 105],
    'Dawn': [255, 199, 95],
    'Dusk': [255, 140, 56],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Orange Family',
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
        itemCount: orangeColors.length,
        itemBuilder: (context, index) {
          final colorName = orangeColors.keys.elementAt(index);
          final rgb = orangeColors[colorName]!;
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
