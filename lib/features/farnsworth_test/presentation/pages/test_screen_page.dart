import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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

  late List<Color?> _availableSlots;
  List<Color?> _placedColors = List.filled(15, null);
  int? _selectedIndex;

  // Tutorial Coach Mark
  List<TargetFocus> targets = [];
  late TutorialCoachMark tutorialCoachMark;

  // Keys for pointing
  final GlobalKey keyPalette = GlobalKey();
  final GlobalKey keyLockedColor = GlobalKey();
  final GlobalKey keyPlacementArea = GlobalKey();
  final GlobalKey keyViewResults = GlobalKey();

  @override
  void initState() {
    super.initState();
    _resetTest();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
  }

  void _showTutorial() {
    targets = [
      TargetFocus(
        identify: "palette",
        keyTarget: keyPalette,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildInstructionBox("Tap a color from here to select it."),
          ),
        ],
      ),
      TargetFocus(
        identify: "lockedColor",
        keyTarget: keyLockedColor,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildInstructionBox(
              "Start arranging from this BLUE color — it's locked in place as your starting point.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "placement",
        keyTarget: keyPlacementArea,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildInstructionBox(
              "Tap a circle here to place your chosen color. Try to make the hues flow smoothly!",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "submit",
        keyTarget: keyViewResults,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildInstructionBox(
              "When all colors are placed, tap here to view your results.",
            ),
          ),
        ],
      ),
    ];

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withValues(alpha: 0.7),
      textSkip: "Skip",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () => debugPrint("Tutorial finished"),
      onSkip: () {
        debugPrint("Tutorial skipped");
        return true;
      },
    );

    tutorialCoachMark.show(context: context);
  }

  Widget _buildInstructionBox(String text) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
      ),
    );
  }

  void _resetTest() {
    setState(() {
      _placedColors = List<Color?>.filled(15, null);
      _placedColors[0] = _colors[0];

      final shuffledColors = List<Color>.from(_colors.sublist(1))..shuffle();
      _availableSlots = List<Color?>.from(shuffledColors);
      _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final placedCount = _placedColors.where((c) => c != null).length;
    final screenWidth = MediaQuery.of(context).size.width;

    final circleSize = (screenWidth - 40 - (8 * 6)) / 7;
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

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B167A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '1. Tap a color from the palette\n'
                  '2. Tap on a blank circle below to place it\n'
                  '3. Begin with the BLUE color at the start that is beside the blank circle.\n'
                  '4. Arrange the other colors so their hues transition smoothly from one to the next.\n'
                  '5. The color should END with the darkest shade of PURPLE that is available',
                  style: TextStyle(color: Color(0xFFCEF5FF)),
                ),
              ),

              const SizedBox(height: 30),

              // Available Colors
              SizedBox(
                key: keyPalette,
                height: circleSize * 2 + 8,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
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
                        decoration: BoxDecoration(
                          color: color ?? Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedIndex == index
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            width: _selectedIndex == index ? 3 : 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Placement Area
              SizedBox(
                key: keyPlacementArea,
                height: gridHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    mainAxisExtent: circleSize,
                  ),
                  itemCount: _placedColors.length,
                  itemBuilder: (context, index) {
                    return Center(
                      key: index == 0 ? keyLockedColor : null,
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
                              ? const Icon(Icons.add,
                                  color: Colors.white30, size: 18)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

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
                key: keyViewResults,
                onPressed: placedCount == 15 ? _showResults : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCEF5FF),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
    if (slotIndex == 0) return;

    setState(() {
      if (_selectedIndex != null && _placedColors[slotIndex] == null) {
        final colorToPlace = _availableSlots[_selectedIndex!];
        _placedColors[slotIndex] = colorToPlace;
        _availableSlots[_selectedIndex!] = null;
        _selectedIndex = null;
      } else if (_placedColors[slotIndex] != null) {
        final colorToRemove = _placedColors[slotIndex]!;
        _placedColors[slotIndex] = null;

        final emptyIndex = _availableSlots.indexOf(null);
        if (emptyIndex != -1) {
          _availableSlots[emptyIndex] = colorToRemove;
        }
      }
    });
  }

  void _showResults() {
    final userOrder = _placedColors.whereType<Color>().toList();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TestResultPage(userColorOrder: userOrder, referenceColors: _colors),
      ),
    );
  }
}
