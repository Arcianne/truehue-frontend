import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:truehue/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:truehue/shared/presentation/widgets/nav_button.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/core/algorithm/knn_color_matcher.dart';
import 'package:truehue/features/color_library/presentation/pages/red_family.dart';
import 'package:truehue/features/color_library/presentation/pages/pink_family.dart';
import 'package:truehue/features/color_library/presentation/pages/orange_family.dart';
import 'package:truehue/features/color_library/presentation/pages/yellow_family.dart';
import 'package:truehue/features/color_library/presentation/pages/green_family.dart';
import 'package:truehue/features/color_library/presentation/pages/blue_family.dart';
import 'package:truehue/features/color_library/presentation/pages/purple_family.dart';
import 'package:truehue/features/color_library/presentation/pages/brown_family.dart';
import 'package:truehue/features/color_library/presentation/pages/white_family.dart';
import 'package:truehue/features/color_library/presentation/pages/gray_family.dart';
import 'package:truehue/features/color_library/presentation/pages/black_family.dart';

Future<void> openARLiveView(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final mode = prefs.getString('liveARMode') ?? 'Assistive';
  final colorBlindType = prefs.getString('colorBlindnessType') ?? 'Normal';

  final bool assistiveMode = mode == 'Assistive';
  final String? simulationType = mode == 'Simulation'
      ? colorBlindType.toLowerCase()
      : null;

  if (!context.mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ArLiveViewPage(
        assistiveMode: assistiveMode,
        simulationType: simulationType,
      ),
    ),
  );
}

void openSelectAPhotoPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const SelectAPhotoPage()),
  );
}

void openTakeAPhotoPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => TakeAPhotoPage(camera: firstCamera),
    ),
  );
}

void openColorLibraryPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const ColorLibraryPage()),
  );
}

void openHomePage(BuildContext context) {
  Navigator.popUntil(context, (route) => route.isFirst);
}

class ColorLibraryPage extends StatefulWidget {
  const ColorLibraryPage({super.key});

  @override
  State<ColorLibraryPage> createState() => _ColorLibraryPageState();
}

class _ColorLibraryPageState extends State<ColorLibraryPage> {
  String _searchQuery = '';
  bool _sortAlphabetical = true;

  String _determineFamilyFromName(String colorName) {
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

  List<MapEntry<String, List<String>>> _getFilteredFamilies() {
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

    final familiesWithColors = <MapEntry<String, List<String>>>[];

    for (final family in colorFamilies) {
      final familyColors = ColorMatcher.allColorNames
          .where((name) => _determineFamilyFromName(name) == family)
          .where(
            (name) =>
                _searchQuery.isEmpty ||
                name.toLowerCase().contains(_searchQuery),
          )
          .toList();

      if (familyColors.isNotEmpty) {
        familiesWithColors.add(MapEntry(family, familyColors));
      }
    }

    // Sort families if needed
    if (!_sortAlphabetical) {
      familiesWithColors.sort(
        (a, b) => b.value.length.compareTo(a.value.length),
      );
    }

    return familiesWithColors;
  }

  int _getFilteredCount() {
    return ColorMatcher.allColorNames
        .where((name) => name.toLowerCase().contains(_searchQuery))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredFamilies = _getFilteredFamilies();

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
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Sort/Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('A-Z'),
                  selected: _sortAlphabetical,
                  onSelected: (value) {
                    setState(() => _sortAlphabetical = value);
                  },
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  selectedColor: Colors.white.withValues(alpha: 0.3),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: _sortAlphabetical
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('By Count'),
                  selected: !_sortAlphabetical,
                  onSelected: (value) {
                    setState(() => _sortAlphabetical = !value);
                  },
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  selectedColor: Colors.white.withValues(alpha: 0.3),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: !_sortAlphabetical
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Total Colors Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _searchQuery.isEmpty
                  ? '${ColorMatcher.colorCount} unique colors'
                  : '${_getFilteredCount()} colors found',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Color Families List or Empty State
          Expanded(
            child: filteredFamilies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No colors found',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredFamilies.length,
                    itemBuilder: (context, index) {
                      final entry = filteredFamilies[index];
                      return _buildColorFamilyCard(entry.key, entry.value);
                    },
                  ),
          ),
        ],
      ),

      // Bottom nav bar
      bottomNavigationBar: Container(
        color: const Color.fromARGB(47, 3, 0, 52),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavButton(
              icon: Icons.upload_outlined,
              label: '',
              onTap: () => openSelectAPhotoPage(context),
            ),
            NavButton(
              icon: Icons.camera_alt,
              label: '',
              onTap: () => openTakeAPhotoPage(context),
            ),
            NavButton(
              icon: Icons.visibility,
              label: '',
              onTap: () => openARLiveView(context),
            ),
            NavButton(
              icon: Icons.menu_book,
              label: '',
              isSelected: true,
              onTap: () {},
            ),
            NavButton(
              icon: Icons.home,
              label: '',
              onTap: () => openHomePage(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorFamilyCard(String family, List<String> familyColors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1570),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();

          // Navigate to specific family page
          Widget familyPage;
          switch (family) {
            case 'Red':
              familyPage = const RedFamilyPage();
              break;
            case 'Pink':
              familyPage = const PinkFamilyPage();
              break;
            case 'Orange':
              familyPage = const OrangeFamilyPage();
              break;
            case 'Yellow':
              familyPage = const YellowFamilyPage();
              break;
            case 'Green':
              familyPage = const GreenFamilyPage();
              break;
            case 'Blue':
              familyPage = const BlueFamilyPage();
              break;
            case 'Purple':
              familyPage = const PurpleFamilyPage();
              break;
            case 'Brown':
              familyPage = const BrownFamilyPage();
              break;
            case 'White':
              familyPage = const WhiteFamilyPage();
              break;
            case 'Gray':
              familyPage = const GrayFamilyPage();
              break;
            case 'Black':
              familyPage = const BlackFamilyPage();
              break;
            default:
              // Fallback to the old detail page for unknown families
              familyPage = ColorFamilyDetailPage(
                family: family,
                colors: familyColors,
              );
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => familyPage),
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
                    color: Colors.white.withValues(alpha: 0.3),
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
                        color: Colors.white.withValues(alpha: 0.6),
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
    final rgb = ColorMatcher.getColorRGB(colorName);
    final color = rgb != null
        ? Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1.0)
        : Colors.white;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1570),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // Optional: Add color detail dialog or copy RGB to clipboard
          _showColorDetails(colorName, rgb);
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
                    if (rgb != null)
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
              Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorDetails(String colorName, List<int>? rgb) {
    // Optional: Show a dialog with more color information
    // You can implement this to show hex values, HSL, etc.
  }
}
