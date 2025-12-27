import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scheduling/AddClassesPages/home_page.dart';
import 'package:scheduling/ExamsPages/add_exam_page.dart';
import 'package:scheduling/FileViewPages/file_upload_page.dart';
import 'package:scheduling/main_layout.dart';
import 'firebase_options.dart';
import 'AddClassesPages/classes_display_page.dart';
import 'AddClassesPages/add_classes_page.dart';
import 'FileViewPages/folders_grid_page.dart';
import 'AddClassesPages/home_page.dart';
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
      home: const MainLayout(),
      routes: {
        '/addclasses': (context) => const AddClassesPage(),
        '/classesdisplay': (context) => const ClassesDisplayPage(),
        '/folderspage': (context) => const FoldersGridPage(),
        '/fileupload': (context) => const FileUploadPage(
              folderId: 'root_folder', // Example folder ID
              userId: 'student_test_user_001', // Example user ID
            
            ) ,
            '/add_exam': (context) => const AddExamPage(), 
      },
    );
  }
}
