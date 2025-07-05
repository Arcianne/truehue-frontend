import 'package:flutter/material.dart';

    class TestScreenPage extends StatefulWidget {
      const TestScreenPage({super.key});

      @override
      State<TestScreenPage> createState() => _TestScreenPageState();
    }

    class _TestScreenPageState extends State<TestScreenPage> {
      final List<Color> availableColors = [
        Color(0xFF67D4F1),
        Color(0xFF65D0E2),
        Color(0xFF67D3D6),
        Color(0xFF75D5C9),
        Color(0xFF6ED0B9),
        Color(0xFF8AC78E),
        Color(0xFFA3BD4F),
        Color(0xFFD0B244),
        Color(0xFFDDA149),
        Color(0xFFE99569),
        Color(0xFFE89784),
        Color(0xFFE999A3),
        Color(0xFFD59FB4),
        Color(0xFFD099C3),
        Color(0xFFC8A7DB),
      ];

      List<Color?> placedColors = List.filled(15, null);

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: const Color(0xFF130E64),
          appBar: AppBar(
            backgroundColor: const Color(0xFF130E64),
            title: const Text('The Farnsworth D-15\nColor Blind Test', style: TextStyle(color: Colors.white)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  '1. Tap a color from the top row.\n'
                  '2. Tap a spot in the bottom row to place it.\n'
                  '3. To move a color back, tap a white spot.\n'
                  '4. Arrange all colors in order.\n'
                  '5. Tap "Show Result" when you\'re done!',
                  style: TextStyle(color: Color(0xFFCEF5FF), fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildTopRow(),
                const SizedBox(height: 20),
                _buildBottomRow(),
              ],
            ),
          ),
        );
      }

      Widget _buildTopRow() {
        return Wrap(
          spacing: 5,
          runSpacing: 5,
          children: availableColors.map((color) {
            return Draggable<Color>(
              data: color,
              feedback: _buildColorDisk(color, elevation: 4, width: 30, height: 60),
              childWhenDragging: _buildColorDisk(Colors.transparent, border: true, width: 30, height: 60),
              child: _buildColorDisk(color, width: 30, height: 60),
            );
          }).toList(),
        );
      }

      Widget _buildBottomRow() {
        return Wrap(
          spacing: 5,
          runSpacing: 5,
          children: List.generate(15, (index) {
            final color = placedColors[index];
            return DragTarget<Color>(
              onAcceptWithDetails: (details) {
                setState(() {
                  placedColors[index] = details.data;
                  availableColors.remove(details.data);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTap: () {
                    if (color != null) {
                      setState(() {
                        availableColors.add(color);
                        placedColors[index] = null;
                      });
                    }
                  },
                  child: _buildColorDisk(color ?? Colors.white, border: true, width: 30, height: 60),
                );
              },
            );
          }),
        );
      }

      Widget _buildColorDisk(Color color, {bool border = false, double elevation = 0, double width = 15, double height = 40}) {
        return Material(
          elevation: elevation,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: border ? Border.all(color: Colors.grey, width: 1) : null,
            ),
          ),
        );
      }
    }
  //