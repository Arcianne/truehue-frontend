import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMode = prefs.getString('liveARMode') ?? 'Assistive';
      _selectedType = prefs.getString('colorBlindnessType') ?? 'Normal';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('liveARMode', _selectedMode);
    await prefs.setString('colorBlindnessType', _selectedType);
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
                // Dropdown for colorblindness type
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
                        setState(() => _selectedType = newValue);
                        _savePreferences();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings saved!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    items: _colorBlindTypes
                        .map(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                  ),
                ),
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
            setState(() => _selectedMode = value);
            _savePreferences();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings saved!'),
                duration: Duration(seconds: 1),
              ),
            );
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
