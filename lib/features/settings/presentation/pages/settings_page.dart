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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/icon/truehue_logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  'Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 36),

                // --- Current Type ---
                Text(
                  'Current type of colorblindness:',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedType,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 30),

                // --- Mode Section ---
                Text(
                  'Mode:',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                _buildModeRadio(
                  'Assistive',
                  'Help me see colors better',
                  theme,
                ),
                _buildModeRadio(
                  'Simulation',
                  'Show how I see to others',
                  theme,
                ),

                const SizedBox(height: 32),

                // --- Dropdown Section ---
                Text(
                  'Select colorblindness type:',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(
                      alpha: 0.25,
                    ), // darker semi-transparent
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedType,
                    dropdownColor: theme.canvasColor.withValues(alpha: 0.95),
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.primaryColor.withValues(alpha: 0.8),
                      size: 28,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontSize: 20,
                    ),
                    itemHeight: 56,

                    // selected item shows only the type name, no description
                    selectedItemBuilder: (BuildContext context) {
                      return _colorBlindTypes.map((value) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: theme.primaryColor,
                            ),
                          ),
                        );
                      }).toList();
                    },

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

                    items: _colorBlindTypes.map((value) {
                      final descriptions = {
                        'Normal': 'No color vision deficiency',
                        'Protanopia':
                            'Red-green color blindness (difficulty distinguishing red hues)',
                        'Deuteranopia':
                            'Red-green color blindness (difficulty distinguishing green hues)',
                        'Tritanopia':
                            'Blue-yellow color blindness (difficulty distinguishing blue and yellow hues)',
                      };

                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          height: 56,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                if (descriptions[value] != null)
                                  Text(
                                    descriptions[value]!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: theme.primaryColor.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 50),

                // --- Farnsworth Test Section ---
                Text(
                  'Farnsworth D-15 Test:',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200,
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Take test again',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        horizontalTitleGap: 4,
        leading: Transform.scale(
          scale: 0.9,
          child: Radio<String>(
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
        ),
        title: Text(
          mode,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.primaryColor.withValues(alpha: 0.7),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
