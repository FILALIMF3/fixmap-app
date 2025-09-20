// lib/main.dart
import 'package:fixmap_app/screens/home_screen.dart';
import 'package:fixmap_app/utils/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async { // <-- 1. Make the function async
  WidgetsFlutterBinding.ensureInitialized(); // <-- 2. ADD THIS LINE
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixMap',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}