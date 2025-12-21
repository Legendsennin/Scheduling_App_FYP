import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taskfission_1/screens/dashboard/dashboard_screen.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Schedule App',

      // ✅ KEEP YOUR THEME
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        primaryColor: const Color(0xFF6C63FF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(),
        ),
      ),

      // ✅ START APP HERE (NO CHANGE)
      home: const DashboardScreen(),
    );
  }
}
