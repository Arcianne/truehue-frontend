import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truehue/features/farnsworth_test/presentation/pages/test_screen_page.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                Text(
                  'Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  'Current type of colorblindness:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedType,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 30),
                Text(
                  'Mode:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                _buildModeRadio(
                  'Assistive',
                  'Help me see colors better',
                  theme,
                ),
                const SizedBox(height: 10),
                _buildModeRadio(
                  'Simulation',
                  'Show how I see to others',
                  theme,
                ),

                const SizedBox(height: 40),

                // Dropdown for colorblindness type
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedType,
                    dropdownColor: theme.scaffoldBackgroundColor,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.primaryColor,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
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

                const SizedBox(height: 50),

                // Farnsworth D-15 Test section (smaller, like the 'current type' text)
                Text(
                  'Farnsworth D-15 Test:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TestScreenPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Take test again',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeRadio(String mode, String description, ThemeData theme) {
    return ListTile(
      leading: Radio<String>(
        value: mode,
        groupValue: _selectedMode,
        activeColor: theme.primaryColor,
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
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.primaryColor.withOpacity(0.7),
        ),
      ),
    );
  }
}
