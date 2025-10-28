import 'package:flutter/material.dart';
import 'package:truehue/features/farnsworth_test/presentation/pages/test_screen_page.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';

class SettingsPage extends StatefulWidget {
  final String initialMode;
  final String initialType;

  const SettingsPage({
    super.key,
    this.initialMode = 'Assistive',
    this.initialType = 'Normal',
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedMode;
  late String _selectedType;

  final List<String> _colorBlindTypes = [
    'Normal',
    'Protanopia',
    'Deuteranopia',
    'Tritanopia',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130E64),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/icon/truehue_logo.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Color(0xFFCEF5FF),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bellota',
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Current type of colorblindness:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                    fontFamily: 'Bellota',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedType,
                  style: const TextStyle(
                    color: Color(0xFFCEF5FF),
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Bellota',
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Mode:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                    fontFamily: 'Bellota',
                  ),
                ),
                const SizedBox(height: 10),
                _buildModeRadio('Assistive', 'Help me see colors better'),
                const SizedBox(height: 10),
                _buildModeRadio('Simulation', 'Show how I see to others'),
                const SizedBox(height: 40),
                // Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedType,
                    dropdownColor: const Color(0xFF130E64),
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFFCEF5FF),
                    ),
                    style: const TextStyle(
                      color: Color(0xFFCEF5FF),
                      fontSize: 16,
                      fontFamily: 'Bellota',
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      }
                    },
                    items: _colorBlindTypes.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                // Take test again
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TestScreenPage(),
                        ),
                      );
                    },
                    child: const Text("Take Farnsworth Test Again"),
                  ),
                ),
                const SizedBox(height: 20),
                // ✅ AR Live button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final assistive = _selectedMode == 'Assistive';
                      final type = _selectedType.toLowerCase();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArLiveViewPage(
                            assistiveMode: assistive,
                            simulationType: assistive
                                ? null
                                : type == 'normal'
                                ? 'protanopia'
                                : type,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Open AR Live View",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeRadio(String mode, String description) {
    return ListTile(
      leading: Radio<String>(
        value: mode,
        groupValue: _selectedMode,
        activeColor: const Color(0xFFCEF5FF),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedMode = value;
            });
          }
        },
      ),
      title: Text(
        mode,
        style: const TextStyle(
          color: Color(0xFFCEF5FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Bellota',
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13,
          fontFamily: 'Bellota',
        ),
      ),
    );
  }
}
