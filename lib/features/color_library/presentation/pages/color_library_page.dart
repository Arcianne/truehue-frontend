import 'package:flutter/material.dart';
import 'package:truehue/main.dart';
import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/core/algorithm/knn_color_matcher.dart';

void openARLiveView(
  BuildContext context,
  bool assistiveMode, {
  String? simulationType,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ArLiveViewPage(
        assistiveMode: assistiveMode,
        simulationType: simulationType,
      ),
    ),
  );
}

void openTakeAPhotoPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TakeAPhotoPage(camera: firstCamera),
    ),
  );
}

void openSelectAPhotoPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SelectAPhotoPage()),
  );
}

void openColorLibraryPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ColorLibraryPage()),
  );
}

class ColorLibraryPage extends StatefulWidget {
  const ColorLibraryPage({super.key});

  @override
  State<ColorLibraryPage> createState() => _ColorLibraryPageState();
}

class _ColorLibraryPageState extends State<ColorLibraryPage> {
  String _searchQuery = '';

  String _determineFamilyFromName(String colorName) {
    // Simple categorization based on name - you might want to use the RGB values instead
    final lower = colorName.toLowerCase();

    if (lower.contains('red') ||
        lower.contains('crimson') ||
        lower.contains('scarlet') ||
        lower.contains('ruby') ||
        lower.contains('cherry') ||
        lower.contains('burgundy') ||
        lower.contains('wine') ||
        lower.contains('cardinal') ||
        lower.contains('brick') ||
        lower.contains('vermillion') ||
        lower.contains('maroon')) {
      return 'Red';
    } else if (lower.contains('pink') ||
        lower.contains('rose') ||
        lower.contains('blush') ||
        lower.contains('fuchsia') ||
        lower.contains('magenta') ||
        lower.contains('carnation')) {
      return 'Pink';
    } else if (lower.contains('orange') ||
        lower.contains('coral') ||
        lower.contains('peach') ||
        lower.contains('apricot') ||
        lower.contains('tangerine') ||
        lower.contains('amber')) {
      return 'Orange';
    } else if (lower.contains('yellow') ||
        lower.contains('lemon') ||
        lower.contains('gold') ||
        lower.contains('butter') ||
        lower.contains('canary') ||
        lower.contains('sunflower')) {
      return 'Yellow';
    } else if (lower.contains('green') ||
        lower.contains('lime') ||
        lower.contains('mint') ||
        lower.contains('emerald') ||
        lower.contains('jade') ||
        lower.contains('olive') ||
        lower.contains('forest') ||
        lower.contains('sage')) {
      return 'Green';
    } else if (lower.contains('blue') ||
        lower.contains('azure') ||
        lower.contains('cyan') ||
        lower.contains('navy') ||
        lower.contains('sky') ||
        lower.contains('cobalt') ||
        lower.contains('sapphire') ||
        lower.contains('teal') ||
        lower.contains('aqua')) {
      return 'Blue';
    } else if (lower.contains('purple') ||
        lower.contains('violet') ||
        lower.contains('lavender') ||
        lower.contains('plum') ||
        lower.contains('lilac') ||
        lower.contains('mauve') ||
        lower.contains('orchid') ||
        lower.contains('indigo')) {
      return 'Purple';
    } else if (lower.contains('brown') ||
        lower.contains('tan') ||
        lower.contains('beige') ||
        lower.contains('chocolate') ||
        lower.contains('coffee') ||
        lower.contains('wood') ||
        lower.contains('chestnut') ||
        lower.contains('mahogany')) {
      return 'Brown';
    } else if (lower.contains('white') ||
        lower.contains('ivory') ||
        lower.contains('pearl') ||
        lower.contains('snow') ||
        lower.contains('cream')) {
      return 'White';
    } else if (lower.contains('black') ||
        lower.contains('ebony') ||
        lower.contains('coal') ||
        lower.contains('jet') ||
        lower.contains('charcoal')) {
      return 'Black';
    } else if (lower.contains('gray') ||
        lower.contains('grey') ||
        lower.contains('silver') ||
        lower.contains('slate') ||
        lower.contains('steel')) {
      return 'Gray';
    }

    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    final colorFamilies = [
      'Red',
      'Pink',
      'Orange',
      'Yellow',
      'Green',
      'Blue',
      'Purple',
      'Brown',
      'Gray',
      'White',
      'Black',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: const Text(
          'Color Library',
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search colors...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Total Colors Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${ColorMatcher.colorCount} unique colors',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Color Families List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: colorFamilies.length,
              itemBuilder: (context, index) {
                final family = colorFamilies[index];
                return _buildColorFamilyCard(family);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF130E64),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavButton(
              icon: Icons.upload_outlined,
              label: '',
              onTap: () {
                openSelectAPhotoPage(context);
              },
            ),
            NavButton(
              icon: Icons.camera_alt,
              label: '',
              isSelected: false,
              onTap: () {
                openTakeAPhotoPage(context);
              },
            ),
            NavButton(
              icon: Icons.visibility,
              label: '',
              onTap: () {
                openARLiveView(context, false);
              },
            ),
            NavButton(
              icon: Icons.menu_book,
              label: '',
              isSelected: true,
              onTap: () {
                // Already in color library
              },
            ),
            NavButton(
              icon: Icons.home,
              label: '',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorFamilyCard(String family) {
    // Filter colors by family and search query
    final familyColors = ColorMatcher.allColorNames
        .where((name) => _determineFamilyFromName(name) == family)
        .where(
          (name) =>
              _searchQuery.isEmpty || name.toLowerCase().contains(_searchQuery),
        )
        .toList();

    if (familyColors.isEmpty && _searchQuery.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1570),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ColorFamilyDetailPage(family: family, colors: familyColors),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Sample color circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getFamilyColor(family),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Family info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$family Family',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${familyColors.length} colors',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
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

  Color _getFamilyColor(String family) {
    switch (family) {
      case 'Red':
        return Colors.red;
      case 'Pink':
        return Colors.pink;
      case 'Orange':
        return Colors.orange;
      case 'Yellow':
        return Colors.yellow;
      case 'Green':
        return Colors.green;
      case 'Blue':
        return Colors.blue;
      case 'Purple':
        return Colors.purple;
      case 'Brown':
        return Colors.brown;
      case 'Gray':
        return Colors.grey;
      case 'White':
        return Colors.white;
      case 'Black':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}

// Detail page for each color family
class ColorFamilyDetailPage extends StatelessWidget {
  final String family;
  final List<String> colors;

  const ColorFamilyDetailPage({
    super.key,
    required this.family,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E64),
        elevation: 0,
        title: Text(
          '$family Family',
          style: const TextStyle(
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
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final colorName = colors[index];
          return _buildColorItem(colorName);
        },
      ),
    );
  }

  Widget _buildColorItem(String colorName) {
    // We need to get RGB values - you'll need to expose them from ColorMatcher
    // For now, using placeholder
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1570),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Color preview circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white, // Replace with actual color
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Color name
            Expanded(
              child: Text(
                colorName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
