import 'package:flutter/material.dart';
import 'package:truehue/features/farnsworth_test/presentation/pages/test_result.dart';

class TestScreenPage extends StatefulWidget {
  const TestScreenPage({super.key});

  @override
  State<TestScreenPage> createState() => _TestScreenPageState();
}

class _TestScreenPageState extends State<TestScreenPage> {
  final List<Color> _colors = [
    const Color(0xFF7E9AC8),
    const Color(0xFF6DA7BA),
    const Color(0xFF61B1A6),
    const Color(0xFF65B88E),
    const Color(0xFF7CBC75),
    const Color(0xFF98BE67),
    const Color(0xFFB6BD5D),
    const Color(0xFFD3B85F),
    const Color(0xFFE2A965),
    const Color(0xFFE89A74),
    const Color(0xFFE58A8B),
    const Color(0xFFD97A9F),
    const Color(0xFFC66FB0),
    const Color(0xFFAB6EBF),
    const Color(0xFF8C74C7),
  ];

  late List<Color?> _availableSlots; // placeholders for available colors
  List<Color?> _placedColors = List.filled(15, null);
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _resetTest();
  }

  void _resetTest() {
    setState(() {
      _placedColors = List<Color?>.filled(15, null);
      _placedColors[0] = _colors[0]; // Reference color fixed

      final shuffledColors = List<Color>.from(_colors.sublist(1))..shuffle();
      _availableSlots = List<Color?>.filled(shuffledColors.length, null);
      for (int i = 0; i < shuffledColors.length; i++) {
        _availableSlots[i] = shuffledColors[i];
      }

      _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final placedCount = _placedColors.where((c) => c != null).length;
    final screenWidth = MediaQuery.of(context).size.width;

    // Compute circle size (fits 7 per row)
    final circleSize = (screenWidth - 40 - (8 * 6)) / 7;

    // Rows for placement area
    final rows = (_placedColors.length / 7).ceil();
    final gridHeight = (circleSize * rows) + (8 * (rows - 1));

    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Color Arrangement Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blue),
                    onPressed: _resetTest,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B167A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '1. Tap a color above\n2. Tap a circle below to place it\n3. Arrange in rainbow order',
                  style: TextStyle(color: Color(0xFFCEF5FF)),
                ),
              ),

              const SizedBox(height: 30),

              // --- Available Colors with white placeholders ---
              SizedBox(
                height: circleSize * 2 + 8,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableSlots.length,
                  itemBuilder: (context, index) {
                    final color = _availableSlots[index];
                    return GestureDetector(
                      onTap: color != null
                          ? () => setState(() => _selectedIndex = index)
                          : null,
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: Colors.white, // white placeholder
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedIndex == index
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            width: _selectedIndex == index ? 3 : 1.5,
                          ),
                        ),
                        child: color != null
                            ? Container(
                                width: circleSize,
                                height: circleSize,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // --- Placement Area ---
              SizedBox(
                height: gridHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    mainAxisExtent: circleSize,
                  ),
                  itemCount: _placedColors.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: GestureDetector(
                        onTap: () => _handleTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            color: _placedColors[index],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: index == 0
                                  ? Colors.blueAccent
                                  : _placedColors[index] == null
                                  ? Colors.white30
                                  : Colors.greenAccent,
                              width: 2,
                            ),
                          ),
                          child: _placedColors[index] == null
                              ? const Icon(
                                  Icons.add,
                                  color: Colors.white30,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Progress
              Text(
                '$placedCount/15 colors placed',
                style: const TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: placedCount / 15,
                minHeight: 6,
                backgroundColor: const Color(0xFF1B167A),
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),

              const Spacer(),

              // Submit button
              ElevatedButton(
                onPressed: placedCount == 15 ? _showResults : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCEF5FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Results',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(int slotIndex) {
    if (slotIndex == 0) return; // Can't move reference color

    setState(() {
      // Placing color
      if (_selectedIndex != null && _placedColors[slotIndex] == null) {
        final colorToPlace = _availableSlots[_selectedIndex!];
        _placedColors[slotIndex] = colorToPlace;
        _availableSlots[_selectedIndex!] = null; // leave placeholder empty
        _selectedIndex = null;
      }
      // Removing color
      else if (_placedColors[slotIndex] != null) {
        final colorToRemove = _placedColors[slotIndex]!;
        _placedColors[slotIndex] = null;

        // return to first empty available slot
        final emptyIndex = _availableSlots.indexOf(null);
        if (emptyIndex != -1) {
          _availableSlots[emptyIndex] = colorToRemove;
        }
      }
    });
  }

void _showResults() {
    // Collect all 15 colors exactly as arranged by the user
    final userOrder = _placedColors.whereType<Color>().toList();

    // Optional sanity check (for debugging)
    debugPrint("User order length: ${userOrder.length}");
    for (int i = 0; i < userOrder.length; i++) {
      debugPrint("Cap $i: ${userOrder[i]}");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TestResultPage(userColorOrder: userOrder, referenceColors: _colors),
      ),
    );
  }
}
