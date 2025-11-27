import 'package:flutter/material.dart';
import 'package:truehue/main.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';
import 'package:truehue/features/settings/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String colorBlindnessType = 'Not set';
  String liveARMode = 'Assistive';

  // Global keys for tutorial targets
  final GlobalKey _liveViewKey = GlobalKey();
  final GlobalKey _takePhotoKey = GlobalKey();
  final GlobalKey _selectPhotoKey = GlobalKey();
  final GlobalKey _colorLibraryKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _checkAndShowTutorial();
  }

  // Reload preferences whenever this page is shown
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      colorBlindnessType = prefs.getString('colorBlindnessType') ?? 'Not set';
      liveARMode = prefs.getString('liveARMode') ?? 'Assistive';
    });
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('hasSeenHomeTutorial') ?? false;

    if (!hasSeenTutorial) {
      // Delay to ensure widgets are built
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showTutorial();
        // Mark tutorial as seen
        await prefs.setBool('hasSeenHomeTutorial', true);
      }
    }
  }

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      alignSkip: Alignment.bottomRight,
      textSkip: "SKIP",
      onFinish: () {
        print('Tutorial finished');
      },
      onSkip: () {
        print('Tutorial skipped');
        return true;
      },
    );

    tutorialCoachMark!.show(context: context);
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "liveView",
        keyTarget: _liveViewKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Live Color View",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Use your camera in real-time to see color adjustments or simulations based on your settings.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "takePhoto",
        keyTarget: _takePhotoKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Take a Photo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Capture a photo and analyze its colors. Perfect for identifying specific colors in your environment.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "selectPhoto",
        keyTarget: _selectPhotoKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Select a Photo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Upload an existing photo from your gallery to analyze its colors.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "colorLibrary",
        keyTarget: _colorLibraryKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Color Library",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Browse and explore a collection of colors. Learn about different color names and their properties.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "settings",
        keyTarget: _settingsKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Configure your color blindness type and Live AR mode. These settings will affect how colors are displayed throughout the app.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  void openARLiveView() {
    final assistive = liveARMode == 'Assistive';
    final typeLower = colorBlindnessType.toLowerCase();

    // Handle "Not set" or "Normal" for assistive mode
    String finalType = typeLower;
    if (assistive && (typeLower == 'normal' || typeLower == 'not set')) {
      finalType = 'protanopia'; // Default for assistive mode
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArLiveViewPage(
          assistiveMode: assistive,
          simulationType: assistive ? null : finalType,
          colorBlindType: finalType,
        ),
      ),
    );
  }

  void openTakeAPhotoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakeAPhotoPage(camera: firstCamera),
      ),
    );
  }

  void openSelectAPhotoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectAPhotoPage()),
    );
  }

  void openColorLibraryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ColorLibraryPage()),
    );
  }

  void openSettingsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    // Reload preferences after returning from Settings
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildBody(context),
            // Top-right settings button
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton(
                key: _settingsKey,
                onPressed: openSettingsPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF130E64),
                  foregroundColor: const Color(0xFFCEF5FF),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                  elevation: 3,
                ),
                child: const Icon(Icons.settings, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 60),
          Image.asset('assets/icon/truehue_logo.png', width: 150, height: 150),
          const SizedBox(height: 10),
          const Text(
            'TrueHue',
            style: TextStyle(
              fontSize: 30,
              fontStyle: FontStyle.italic,
              color: Color(0xFFCEF5FF),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            height: 60,
            child: ElevatedButton(
              key: _liveViewKey,
              onPressed: openARLiveView,
              child: Row(
                children: const [
                  SizedBox(width: 16),
                  Icon(Icons.visibility, size: 24),
                  SizedBox(width: 16),
                  Text('Live Color View', style: TextStyle(fontSize: 25)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            height: 60,
            child: ElevatedButton(
              key: _takePhotoKey,
              onPressed: openTakeAPhotoPage,
              child: Row(
                children: const [
                  SizedBox(width: 16),
                  Icon(Icons.camera_alt, size: 24),
                  SizedBox(width: 16),
                  Text('Take a Photo', style: TextStyle(fontSize: 25)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            height: 60,
            child: ElevatedButton(
              key: _selectPhotoKey,
              onPressed: openSelectAPhotoPage,
              child: Row(
                children: const [
                  SizedBox(width: 16),
                  Icon(Icons.upload_outlined, size: 24),
                  SizedBox(width: 16),
                  Text('Select a Photo', style: TextStyle(fontSize: 25)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            height: 60,
            child: ElevatedButton(
              key: _colorLibraryKey,
              onPressed: openColorLibraryPage,
              child: Row(
                children: const [
                  SizedBox(width: 16),
                  Icon(Icons.menu_book, size: 24),
                  SizedBox(width: 16),
                  Text('Color Library', style: TextStyle(fontSize: 25)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Color Blindness Type: $colorBlindnessType'),
          Text('Live AR Mode: $liveARMode'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tutorialCoachMark?.finish();
    super.dispose();
  }
}