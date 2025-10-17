import 'package:flutter/material.dart';
import 'package:truehue/features/home/presentation/pages/home.dart';
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
                MaterialPageRoute(builder: (context) => const Home()),
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
                'Go to Home',
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

  List<int> _computeErrors(List<int> userOrder) {
    final List<int> errors = [];
    for (int i = 1; i < userOrder.length; i++) {
      final prev = userOrder[i - 1];
      final curr = userOrder[i];
      if (prev != -1 && curr != -1 && (curr - prev).abs() >= 2) {
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
    final (diagnosis, severity, type) = _calculateDiagnosis(
      errors,
      unused,
      total,
      protan,
      deutan,
      tritan,
    );

    return DiagnosisResult(
      diagnosis: diagnosis,
      errors: errors,
      unusedCaps: unused,
      totalLength: total.round(),
      protanPercentage: _calcPercentage(protan, total),
      deutanPercentage: _calcPercentage(deutan, total),
      tritanPercentage: _calcPercentage(tritan, total),
      severity: severity,
      type: type,
    );
  }

  (String, String, String) _calculateDiagnosis(
    int errors,
    int unused,
    double total,
    double protan,
    double deutan,
    double tritan,
  ) {
    if (errors == 0 && unused == 0 && total < 250) {
      return ("NORMAL RESULT", "NORMAL", "NORMAL");
    }
    if (errors <= 2 && total < 250) {
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
    final (type, severity) = _determineType(protan, deutan, tritan, unused);
    return ("COLOR VISION DEFICIENCY - $severity $type", severity, type);
  }

  (String, String) _determineType(
    double protan,
    double deutan,
    double tritan,
    int unused,
  ) {
    if (deutan > protan * 0.94 && deutan > tritan) {
      return ("DEUTAN", _getSeverity(deutan, unused));
    }
    if (protan > deutan * 0.94 && protan > tritan) {
      return ("PROTAN", _getSeverity(protan, unused));
    }
    if (tritan > deutan && tritan > protan) {
      return ("TRITAN", _getSeverity(tritan, unused, isTritan: true));
    }
    return ("NON-SPECIFIC", "MODERATE");
  }

  String _getSeverity(double length, int unused, {bool isTritan = false}) {
    if (length < 700 && unused < 2) return "MILD";
    if (length < 1100 && unused < 3) return "MODERATE";
    return "SEVERE";
  }

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
