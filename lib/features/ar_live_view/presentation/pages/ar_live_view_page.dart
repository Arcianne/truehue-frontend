import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ARLiveViewPage extends StatefulWidget {
  const ARLiveViewPage({super.key});

  @override
  State<ARLiveViewPage> createState() => _ARLiveViewPageState();
}

class _ARLiveViewPageState extends State<ARLiveViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Live View'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'AR Live View',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Camera view will be displayed here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

void openARLiveView(BuildContext context) async {
  var status = await Permission.camera.status;

  if (!status.isGranted) {
    status = await Permission.camera.request();
  }

  // Check if the widget is still mounted before using context
  if (!context.mounted) return;

  if (status.isGranted) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ARLiveViewPage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera permission is required to use AR live view')),
    );
  }
}

