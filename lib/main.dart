// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WebcamStreamingApp());
}

class WebcamStreamingApp extends StatelessWidget {
  const WebcamStreamingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webcam Streaming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue.shade400,
          secondary: Colors.blueAccent,
          background: const Color(0xFF0a0a0a),
          surface: const Color(0xFF1a1a1a),
        ),
        scaffoldBackgroundColor: const Color(0xFF0a0a0a),
      ),
      home: const HomeScreen(),
    );
  }
}
