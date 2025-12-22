import 'package:flutter/material.dart';

// 1. IMPORT YOUR SEPARATE PAGE FILES HERE
import 'AddClassesPages/classes_display_page.dart';
import 'FileViewPages/folders_grid_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // 2. ADD THE IMPORTED CLASSES TO THIS LIST
  final List<Widget> _pages = const [
    ClassesDisplayPage(), // Comes from classes_display_page.dart
    FoldersGridPage(),    // Comes from folders_grid_page.dart
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The IndexedStack keeps the state of your individual files
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'Tasks',
          ),
           NavigationDestination(
            icon: Icon(Icons.school),
            label: 'Classes',
          ), NavigationDestination(
            icon: Icon(Icons.folder),
            label: 'Folders',
          ),
        ],
      ),
    );
  }
}

 