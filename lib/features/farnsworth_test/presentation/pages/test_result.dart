import 'package:flutter/material.dart';
import 'package:truehue/features/onboarding/presentation/pages/mode_selection_page.dart';
import 'dart:math';

class TestResultPage extends StatelessWidget {
  final List<Color?> userColorOrder;
  final List<Color> referenceColors;

  const TestResultPage({
    super.key,
    required this.userColorOrder,
    required this.referenceColors,
  });

  @override
  Widget build(BuildContext context) {
    final diagnosis = ColorVisionDiagnosis(
      userColorOrder,
      referenceColors,
    ).analyze();

    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildDiagnosisText('DIAGNOSIS: ${diagnosis.diagnosis}'),
            const SizedBox(height: 20),
            _buildDiagnosisText(
              'Errors: ${diagnosis.errors}, Unused caps: ${diagnosis.unusedCaps}',
            ),
            const SizedBox(height: 40),
            _buildAnalysisContainer(diagnosis),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModeSelectionPage(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCEF5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisText(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFFCEF5FF),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    textAlign: TextAlign.center,
  );

  Widget _buildAnalysisContainer(DiagnosisResult diagnosis) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFCEF5FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        _buildPercentageBar(
          'PROTAN (Red)',
          diagnosis.protanPercentage,
          Colors.red,
        ),
        const SizedBox(height: 10),
        _buildPercentageBar(
          'DEUTAN (Green)',
          diagnosis.deutanPercentage,
          Colors.green,
        ),
        const SizedBox(height: 10),
        _buildPercentageBar(
          'TRITAN (Blue)',
          diagnosis.tritanPercentage,
          Colors.blue,
        ),
        const SizedBox(height: 15),
        Text(
          _getResultAnalysis(diagnosis),
          style: const TextStyle(color: Colors.black, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildPercentageBar(String label, int percentage, Color color) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $percentage%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  String _getResultAnalysis(DiagnosisResult diagnosis) {
    if (diagnosis.type == "NORMAL") {
      return 'Your color vision appears to be normal. You have good color discrimination ability.';
    }
    if (diagnosis.type == "NON-SPECIFIC") {
      return 'You show signs of color vision deficiency. The test indicates general color discrimination difficulties.';
    }
    return 'The test suggests ${diagnosis.severity.toLowerCase()} ${diagnosis.type.toLowerCase()} color vision deficiency. This affects your ability to distinguish certain colors.';
  }
}

class ColorVisionDiagnosis {
  final List<Color?> userColorOrder;
  final List<Color> referenceColors;

  // Reference 2D coordinates for accurate vector calculation
  static const List<Offset> _referenceCoordinates = [
    Offset(70, 190),
    Offset(95, 142),
    Offset(130, 106),
    Offset(178, 81),
    Offset(213, 75),
    Offset(262, 81),
    Offset(322, 105),
    Offset(360, 153),
    Offset(372, 238),
    Offset(359, 310),
    Offset(323, 346),
    Offset(274, 370),
    Offset(238, 370),
    Offset(179, 357),
    Offset(142, 337),
    Offset(94, 285),
  ];

  ColorVisionDiagnosis(this.userColorOrder, this.referenceColors);

  DiagnosisResult analyze() {
    final userOrder = _getUserOrderIndices();
    final errors = _computeErrors(userOrder);
    final unusedCaps = userColorOrder.where((c) => c == null).length;

    double totalLength = 0;
    double protanLength = 0;
    double deutanLength = 0;
    double tritanLength = 0;

    for (int i = 1; i < userOrder.length; i++) {
      final prevIndex = userOrder[i - 1];
      final currIndex = userOrder[i];

      if (_isValidIndex(prevIndex) && _isValidIndex(currIndex)) {
        final dx =
            _referenceCoordinates[currIndex].dx -
            _referenceCoordinates[prevIndex].dx;
        final dy =
            _referenceCoordinates[currIndex].dy -
            _referenceCoordinates[prevIndex].dy;
        final length = sqrt(dx * dx + dy * dy);
        final slope = atan2(dy, dx);

        totalLength += length;

        // Categorize by slope
        final adjustedSlope = slope < 0 ? pi + slope : slope;
        if (adjustedSlope < 1.54) {
          protanLength += length;
        } else if (adjustedSlope < 2.6) {
          deutanLength += length;
        } else {
          tritanLength += length;
        }
      }
    }

    return _determineDiagnosis(
      errors.length,
      unusedCaps,
      totalLength,
      protanLength,
      deutanLength,
      tritanLength,
    );
  }

  bool _isValidIndex(int index) =>
      index >= 0 && index < _referenceCoordinates.length;

  List<int> _getUserOrderIndices() {
    final indices = [0]; // reference first
    for (final color in userColorOrder) {
      indices.add(color != null ? _findColorIndex(color) : -1);
    }
    return indices;
  }

  int _findColorIndex(Color color) {
    final value = color.toARGB32();
    for (int i = 0; i < referenceColors.length; i++) {
      if (value == referenceColors[i].toARGB32()) return i;
    }
    return -1;
  }

  // More tolerant error detection: ignore small adjacent mistakes by requiring a bigger jump
  List<int> _computeErrors(List<int> userOrder) {
    final List<int> errors = [];
    for (int i = 1; i < userOrder.length; i++) {
      final prev = userOrder[i - 1];
      final curr = userOrder[i];
      // require a jump of 3 or more positions to count as an error (reduces false positives)
      if (prev != -1 && curr != -1 && (curr - prev).abs() >= 3) {
        if (!errors.contains(prev)) errors.add(prev);
        if (!errors.contains(curr)) errors.add(curr);
      }
    }
    return errors;
  }

  DiagnosisResult _determineDiagnosis(
    int errors,
    int unused,
    double total,
    double protan,
    double deutan,
    double tritan,
  ) {
    final result = _calculateDiagnosis(
      errors,
      unused,
      total,
      protan,
      deutan,
      tritan,
    );

    return DiagnosisResult(
      diagnosis: result.$1,
      errors: errors,
      unusedCaps: unused,
      totalLength: total.round(),
      protanPercentage: _calcPercentage(protan, total),
      deutanPercentage: _calcPercentage(deutan, total),
      tritanPercentage: _calcPercentage(tritan, total),
      severity: result.$2,
      type: result.$3,
    );
  }

  // Updated thresholds and logic to avoid false-positive "mild protan" for very small deviations
  (String, String, String) _calculateDiagnosis(
    int errors,
    int unused,
    double total,
    double protan,
    double deutan,
    double tritan,
  ) {
    // If very few errors and all caps used -> normal
    if (errors <= 1 && unused == 0 && total < 350) {
      return ("NORMAL RESULT", "NORMAL", "NORMAL");
    }

    // If only small issues (<=2 errors) but some unused, treat as non-specific mild
    if (errors <= 2 && total < 400) {
      if (unused == 0) return ("NORMAL RESULT", "NORMAL", "NORMAL");
      if (unused == 1) {
        return (
          "NON-SPECIFIC COLOR VISION DEFICIENCY - MILD",
          "MILD",
          "NON-SPECIFIC",
        );
      }
      if (unused == 2) {
        return (
          "NON-SPECIFIC COLOR VISION DEFICIENCY - MODERATE",
          "MODERATE",
          "NON-SPECIFIC",
        );
      }
      return (
        "NON-SPECIFIC COLOR VISION DEFICIENCY - SEVERE",
        "SEVERE",
        "NON-SPECIFIC",
      );
    }

    // Convert to percentages to reason about dominance
    final pPerc = _calcPercentage(protan, total);
    final dPerc = _calcPercentage(deutan, total);
    final tPerc = _calcPercentage(tritan, total);

    // Determine dominant channel but require both an absolute threshold and a margin over second best
    final percentages = [pPerc, dPerc, tPerc];
    final maxPerc = percentages.reduce(max);
    final secondBest = (percentages..sort()).reversed
        .skip(1)
        .firstWhere((_) => true, orElse: () => 0);

    // convert to doubles for comparisons
    final maxDouble = maxPerc.toDouble();
    final secondDouble = secondBest.toDouble();

    // dominance criteria: at least 40% of total vector length and at least 12 percentage points higher than second best
    const dominanceThreshold = 40;
    const dominanceMargin = 12;

    if (maxPerc >= dominanceThreshold &&
        (maxDouble - secondDouble) >= dominanceMargin) {
      if (pPerc == maxPerc) {
        return (
          "COLOR VISION DEFICIENCY - ",
          _getSeverityFromPercent(pPerc, unused),
          "PROTAN",
        );
      } else if (dPerc == maxPerc) {
        return (
          "COLOR VISION DEFICIENCY - ",
          _getSeverityFromPercent(dPerc, unused),
          "DEUTAN",
        );
      } else if (tPerc == maxPerc) {
        return (
          "COLOR VISION DEFICIENCY - ",
          _getSeverityFromPercent(tPerc, unused, isTritan: true),
          "TRITAN",
        );
      }
    }

    // If nothing strongly dominant, classify as non-specific moderate
    return (
      "NON-SPECIFIC COLOR VISION DEFICIENCY - MODERATE",
      "MODERATE",
      "NON-SPECIFIC",
    );
  }

  String _getSeverityFromPercent(
    int percent,
    int unused, {
    bool isTritan = false,
  }) {
    // map percentage to severity with some empirical thresholds
    if (percent < 45 && unused < 2) return "MILD";
    if (percent < 70 && unused < 3) return "MODERATE";
    return "SEVERE";
  }

  // String _getSeverity(double length, int unused, {bool isTritan = false}) {
  //   if (length < 700 && unused < 2) return "MILD";
  //   if (length < 1100 && unused < 3) return "MODERATE";
  //   return "SEVERE";
  // }

  int _calcPercentage(double part, double total) =>
      total > 0 ? (part / total * 100).round() : 0;
}

class DiagnosisResult {
  final String diagnosis;
  final int errors;
  final int unusedCaps;
  final int totalLength;
  final int protanPercentage;
  final int deutanPercentage;
  final int tritanPercentage;
  final String severity;
  final String type;

  const DiagnosisResult({
    required this.diagnosis,
    required this.errors,
    required this.unusedCaps,
    required this.totalLength,
    required this.protanPercentage,
    required this.deutanPercentage,
    required this.tritanPercentage,
    required this.severity,
    required this.type,
  });
}
