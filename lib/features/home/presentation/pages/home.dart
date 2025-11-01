import 'package:flutter/material.dart';
import 'package:truehue/main.dart';
import 'package:truehue/features/ar_live_view/presentation/pages/ar_live_view_page.dart';
import 'package:truehue/features/select_a_photo/presentation/pages/select_a_photo_page.dart';
import 'package:truehue/features/take_a_photo/presentation/pages/take_a_photo_page.dart';
import 'package:truehue/features/color_library/presentation/pages/color_library_page.dart';
import 'package:truehue/features/settings/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String colorBlindnessType = 'Not set';
  String liveARMode = 'Assistive'; // default to Assistive

  @override
  void initState() {
    super.initState();
    _loadPreferences();
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

  void openARLiveView() {
    final assistive = liveARMode == 'Assistive';
    final typeLower = colorBlindnessType.toLowerCase();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArLiveViewPage(
          assistiveMode: assistive,
          simulationType: assistive
              ? null
              : typeLower == 'normal'
              ? 'protanopia'
              : typeLower,
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
              color: Color(0xFF130E64),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.visibility, size: 24),
            label: const Text('AR Live View', style: TextStyle(fontSize: 25)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(260, 60)),
            onPressed: openARLiveView,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt, size: 24),
            label: const Text('Take a Photo', style: TextStyle(fontSize: 25)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(260, 60)),
            onPressed: openTakeAPhotoPage,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_outlined, size: 24),
            label: const Text('Select a Photo', style: TextStyle(fontSize: 25)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(260, 60)),
            onPressed: openSelectAPhotoPage,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.menu_book, size: 24),
            label: const Text('Color Library', style: TextStyle(fontSize: 25)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(260, 60)),
            onPressed: openColorLibraryPage,
          ),
          // Display saved selections
          Text('Color Blindness Type: $colorBlindnessType'),
          Text('Live AR Mode: $liveARMode'),
        ],
      ),
    );
  }
}