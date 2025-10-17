import 'package:flutter/material.dart';
import 'package:truehue/config/theme/theme.dart';
import 'features/home/presentation/pages/home.dart';
import 'package:camera/camera.dart';

late final CameraDescription firstCamera;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  firstCamera = cameras.first;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueHue',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const Home(),
    );
  }
}
