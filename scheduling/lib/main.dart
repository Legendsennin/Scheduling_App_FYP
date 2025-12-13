import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'AddClassesPages/classes_display_page.dart';
import 'AddClassesPages/add_classes_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // This ensures the blue color looks consistent across devices
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A7BEE)),
      ),
      home: const ClassesDisplayPage(),
      routes: {
        '/addclasses': (context) => const AddClassesPage(),
        '/classesdisplay': (context) => const ClassesDisplayPage(),
      },
    );
  }
}
