import 'package:flutter/material.dart';
import 'package:truehue/config/theme/theme.dart';
import 'package:truehue/features/home/presentation/pages/home.dart';
import 'package:truehue/features/onboarding/presentation/pages/welcome.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final CameraDescription firstCamera;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize camera
  final cameras = await availableCameras();
  firstCamera = cameras.first;

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueHue',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Show Home or Welcome based on onboarding
      home: hasSeenOnboarding ? const Home() : const Welcome(),
    );
  }
}
