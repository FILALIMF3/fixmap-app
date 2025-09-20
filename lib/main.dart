// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

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
      // This is our new, custom theme
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define a modern style for all input fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        // Define a modern style for all buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}