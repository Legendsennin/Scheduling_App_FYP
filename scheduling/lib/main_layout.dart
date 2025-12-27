import 'package:flutter/material.dart';

// 1. IMPORT YOUR SEPARATE PAGE FILES HERE
import 'AddClassesPages/classes_display_page.dart';
import 'FileViewPages/folders_grid_page.dart';
import 'AddclassesPages/home_page.dart';
import 'screens/tasks_page.dart';  
import 'screens/calendar_page.dart';
import 'ExamsPages/exam_list_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // 2. ADD THE IMPORTED CLASSES TO THIS LIST
  final List<Widget> _pages = const [
    HomePage(),   // Comes from dashboard_screen.dart
    CalendarPage(),    // Comes from schedule_screen.dart
    TasksPage(),     // Comes from profile_screen.dart
        ExamListPage(),    // Comes from exam_list_page.dart
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
        backgroundColor:Color.fromARGB(226, 255, 255, 255),
        indicatorColor: Color(0xFF4A7BEE),
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
            icon: Icon(Icons.quiz),
            label: 'Exams',
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


/*bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: const Color(0xFF4A72FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Classes"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Folders"),
        ],
      ),
 */