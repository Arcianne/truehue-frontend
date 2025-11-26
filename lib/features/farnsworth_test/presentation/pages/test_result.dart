import 'package:flutter/material.dart';
import 'package:truehue/features/onboarding/presentation/pages/mode_selection_page.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
// ---------------------------------------------
// TEST RESULT PAGE
// ---------------------------------------------
class TestResultPage extends StatefulWidget {
  final List<Color?> userColorOrder;
  final List<Color> referenceColors;

  const TestResultPage({
    super.key,
    required this.userColorOrder,
    required this.referenceColors,
  });

  @override
  State<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {
  late DiagnosisResult diagnosis;

@override
  void initState() {
    super.initState();
    // Analyze the color vision test
    diagnosis = ColorVisionDiagnosis(
      widget.userColorOrder,
      widget.referenceColors,
    ).analyze(debug: true);

    // Save the result to SharedPreferences
    _saveColorBlindnessType(diagnosis.type);
  }

    Future<void> _saveColorBlindnessType(String type) async {
    final prefs = await SharedPreferences.getInstance();

    // Map test result types to settings format
    String mappedType;
    switch (type.toUpperCase()) {
      case 'PROTAN':
        mappedType = 'Protanopia';
        break;
      case 'DEUTAN':
        mappedType = 'Deuteranopia';
        break;
      case 'TRITAN':
        mappedType = 'Tritanopia';
        break;
      case 'NORMAL':
        mappedType = 'Normal';
        break;
      default:
        mappedType = 'Normal'; // Default for NON-SPECIFIC or unknown
        break;
    }

    await prefs.setString('colorBlindnessType', mappedType);
    debugPrint('✅ Saved color blindness type: $type -> $mappedType');
  }

  @override
  Widget build(BuildContext context) {
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
              'TES: ${diagnosis.totalLength}, '
              'C-index: ${diagnosis.cIndex.toStringAsFixed(2)}, '
              'Angle: ${diagnosis.angleDeg.toStringAsFixed(1)}°',
            ),
            const SizedBox(height: 20),
            _buildDiagnosisText(
              'Unused Caps: ${diagnosis.unusedCaps}, '
              'Severity: ${diagnosis.severity}',
            ),
            const SizedBox(height: 20),
            _buildDiagnosisText('Crossings: ${diagnosis.errors}'),
            const SizedBox(height: 40),
            _buildAnalysisContainer(diagnosis),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
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
      return _severityDisplay("Normal");
    }
    if (diagnosis.type == "NON-SPECIFIC") {
      return "You show non-specific color discrimination difficulty. Consider retesting under proper lighting.";
    }

    // For Protan, Deutan, Tritan — use severity description
    final baseDesc = _severityDisplay(diagnosis.severity);
    return "$baseDesc\n\nThis pattern suggests a ${diagnosis.severity.toLowerCase()} ${diagnosis.type.toLowerCase()} deficiency — your ability to distinguish certain hues (around the ${diagnosis.type.toLowerCase()} axis) may be reduced.";
  }
}

String _severityDisplay(String severity) {
  switch (severity) {
    case "Normal":
      return "Your color vision appears normal — good color discrimination ability.";
    case "Mild":
      return "Your results are close to normal — minor variations detected in color ordering.";
    case "Moderate":
      return "You show moderate color discrimination difficulty — some hues may be challenging to distinguish.";
    case "Severe":
      return "You show severe difficulty distinguishing certain hues. Consider consulting an eye specialist for confirmation.";
    default:
      return "Your test result is inconclusive. Please retake the test under proper lighting conditions.";
  }
}

// ---------------------------------------------
// DIAGNOSIS + CDV COMPUTATION (Enhanced + Auto-Calibrated)
// ---------------------------------------------
class ColorVisionDiagnosis {
  final List<Color?> userColorOrder;
  final List<Color> referenceColors;

  ColorVisionDiagnosis(this.userColorOrder, this.referenceColors);

  DiagnosisResult analyze({bool debug = false, double useAngleCutoff = 5.0}) {
    final validColors = userColorOrder.whereType<Color>().toList();
    final n = validColors.length;
    if (n < 2) {
      return const DiagnosisResult.empty();
    }

    final luvCaps = validColors.map((c) => _toLuv(c)).toList();

    double TES = 0.0;
    List<_Vec> segments = [];

    for (int i = 1; i < luvCaps.length; i++) {
      final dx = luvCaps[i].u - luvCaps[i - 1].u;
      final dy = luvCaps[i].v - luvCaps[i - 1].v;
      final segLen = sqrt(dx * dx + dy * dy);
      TES += segLen;
      segments.add(_Vec(dx, dy, segLen));
    }

    // --- Auto-calibrate TES scaling ---
    final refLuv = referenceColors.map((c) => _toLuv(c)).toList();
    double refTES = 0.0;
    for (int i = 1; i < refLuv.length; i++) {
      final dx = refLuv[i].u - refLuv[i - 1].u;
      final dy = refLuv[i].v - refLuv[i - 1].v;
      refTES += sqrt(dx * dx + dy * dy);
    }
    final refAvgDeltaE = refTES / (refLuv.length - 1);
    final tesScale = 3.0 / refAvgDeltaE;

    final TESnorm = TES * tesScale;
    final cIndex = (TES / (n - 1)) * tesScale;

    // --- Compute user angle ---
    double sumDx = 0.0, sumDy = 0.0;
    for (final s in segments) {
      sumDx += s.dx * s.len;
      sumDy += s.dy * s.len;
    }

    double meanAngleRad = atan2(sumDy, sumDx);
    double meanAngleDeg = _normalizeAngleDegrees(meanAngleRad * 180 / pi);

    // --- Auto-calibrate rotation offset using reference sequence ---
    double refSumDx = 0.0, refSumDy = 0.0;
    for (int i = 1; i < refLuv.length; i++) {
      final dx = refLuv[i].u - refLuv[i - 1].u;
      final dy = refLuv[i].v - refLuv[i - 1].v;
      refSumDx += dx;
      refSumDy += dy;
    }
    double refAngleDeg = _normalizeAngleDegrees(
      atan2(refSumDy, refSumDx) * 180 / pi,
    );

// Apply fine-tuning offset (~+35°) to align your color palette’s "normal" axis to 0°
    double calibratedAngleDeg = _normalizeAngleDegrees(
      meanAngleDeg - refAngleDeg + 35,
    );

    // --- Determine type (Protan/Deutan/Tritan) ---
    String type = "NON-SPECIFIC";
    final absAngle = calibratedAngleDeg.abs();
    if (absAngle >= 60 && absAngle <= 120) {
      type = "TRITAN";
    } else if (absAngle <= 5) {
      type = "NORMAL";
    } else if (calibratedAngleDeg > 5) {
      type = "PROTAN";
    } else {
      type = "DEUTAN";
    }


    // --- Percent similarity calculation ---
    final dProt = _angularDistanceDeg(calibratedAngleDeg, 25.0);
    final dDeut = _angularDistanceDeg(calibratedAngleDeg, -25.0);
    final dTrit = _angularDistanceDeg(calibratedAngleDeg, 100.0);

    double score(double d) => max(0.0, (60.0 - d) / 60.0);
    final sProt = score(dProt);
    final sDeut = score(dDeut);
    final sTrit = score(dTrit);
    final sumScores = sProt + sDeut + sTrit;

    int protPct = 0, deutPct = 0, tritPct = 0;
    if (sumScores > 0) {
      protPct = (100 * sProt / sumScores).round();
      deutPct = (100 * sDeut / sumScores).round();
      tritPct = (100 * sTrit / sumScores).round();
    }

    int crossings = _computeCrossings(luvCaps);
    double sIndex = sqrt(pow(TESnorm, 2) / (TESnorm + crossings + 0.0001));

    final failed = (TESnorm > 18.0) || (cIndex > 1.78);
    final severity = _severityFromCIndex(cIndex, TESnorm);

    final diagnosis = failed
        ? "Color Vision Deficiency - $severity $type"
        : "Normal Color Vision";

    if (debug) {
      debugPrint("===== Farnsworth D15 Analysis =====");
      debugPrint(
        "Ref ΔE avg: ${refAvgDeltaE.toStringAsFixed(2)} → TES scale: ${tesScale.toStringAsFixed(3)}",
      );
      debugPrint(
        "Raw TES: ${TES.toStringAsFixed(2)} → Scaled TES: ${TESnorm.toStringAsFixed(2)}",
      );
      debugPrint("C-index: ${cIndex.toStringAsFixed(2)}");
      debugPrint(
        "Raw angle: ${meanAngleDeg.toStringAsFixed(2)}°, "
        "Ref angle: ${refAngleDeg.toStringAsFixed(2)}°, "
        "→ Calibrated: ${calibratedAngleDeg.toStringAsFixed(2)}°",
      );
      debugPrint("Crossings: $crossings");
      debugPrint("S-index: ${sIndex.toStringAsFixed(2)}");
      debugPrint("Type: $type");
      debugPrint("Severity: $severity");
      debugPrint("Protan: $protPct%, Deutan: $deutPct%, Tritan: $tritPct%");
      debugPrint("===================================");
    }

    return DiagnosisResult(
      diagnosis: diagnosis,
      errors: crossings,
      unusedCaps: userColorOrder.where((c) => c == null).length,
      totalLength: TESnorm.round(),
      cIndex: cIndex,
      angleDeg: calibratedAngleDeg,
      protanPercentage: protPct,
      deutanPercentage: deutPct,
      tritanPercentage: tritPct,
      severity: severity,
      type: type,
    );
  }

  // -------------------------------
  // Helper functions
  // -------------------------------
  int _computeCrossings(List<_CIELuv> caps) {
    int crossings = 0;
    List<double> angles = [];
    for (int i = 1; i < caps.length; i++) {
      final dx = caps[i].u - caps[i - 1].u;
      final dy = caps[i].v - caps[i - 1].v;
      angles.add(atan2(dy, dx));
    }
    for (int i = 1; i < angles.length; i++) {
      if ((angles[i] - angles[i - 1]).abs() > pi / 2) crossings++;
    }
    return crossings;
  }

  String _severityFromCIndex(double cIndex, double TES) {
    if (TES <= 50 && cIndex <= 3.5) return "Normal";
    if (cIndex <= 4.0) return "Mild";
    if (cIndex <= 5.0) return "Moderate";
    return "Severe";
  }


  double _normalizeAngleDegrees(double angle) {
    double a = angle % 360;
    if (a > 180) a -= 360;
    if (a <= -180) a += 360;
    return a;
  }

  double _angularDistanceDeg(double a, double b) {
    final diff = ((a - b) % 360).abs();
    return diff <= 180 ? diff : 360 - diff;
  }

  _CIELuv _toLuv(Color color) {
    double r = color.red / 255, g = color.green / 255, b = color.blue / 255;

    r = (r > 0.04045) ? pow((r + 0.055) / 1.055, 2.4).toDouble() : r / 12.92;
    g = (g > 0.04045) ? pow((g + 0.055) / 1.055, 2.4).toDouble() : g / 12.92;
    b = (b > 0.04045) ? pow((b + 0.055) / 1.055, 2.4).toDouble() : b / 12.92;

    double X = r * 0.4124 + g * 0.3576 + b * 0.1805;
    double Y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    double Z = r * 0.0193 + g * 0.1192 + b * 0.9505;

    const Xn = 0.95047, Yn = 1.0, Zn = 1.08883;
    double denom = (X + 15 * Y + 3 * Z);
    double uPrime = denom == 0 ? 0 : (4 * X) / denom;
    double vPrime = denom == 0 ? 0 : (9 * Y) / denom;
    double ur = (4 * Xn) / (Xn + 15 * Yn + 3 * Zn);
    double vr = (9 * Yn) / (Xn + 15 * Yn + 3 * Zn);

    double L = (Y / Yn > pow(6 / 29, 3))
        ? 116 * pow(Y / Yn, 1 / 3) - 16
        : (Y / Yn) * pow(29 / 3, 3);

    double u = 13 * L * (uPrime - ur);
    double v = 13 * L * (vPrime - vr);
    return _CIELuv(L, u, v);
  }
}

class _Vec {
  final double dx, dy, len;
  _Vec(this.dx, this.dy, this.len);
}

class _CIELuv {
  final double L, u, v;
  _CIELuv(this.L, this.u, this.v);
}

// ---------------------------------------------
// DIAGNOSIS RESULT MODEL
// ---------------------------------------------
class DiagnosisResult {
  final String diagnosis;
  final int errors;
  final int unusedCaps;
  final int totalLength;
  final double cIndex;
  final double angleDeg;
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
    required this.cIndex,
    required this.angleDeg,
    required this.protanPercentage,
    required this.deutanPercentage,
    required this.tritanPercentage,
    required this.severity,
    required this.type,
  });

  const DiagnosisResult.empty()
    : diagnosis = "Insufficient data",
      errors = 0,
      unusedCaps = 15,
      totalLength = 0,
      cIndex = 0,
      angleDeg = 0,
      protanPercentage = 0,
      deutanPercentage = 0,
      tritanPercentage = 0,
      severity = "N/A",
      type = "N/A";
}
