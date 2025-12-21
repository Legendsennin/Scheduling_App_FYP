import 'package:flutter/material.dart';
import '../tasks/tasks_screen.dart';


class DashboardScreen extends StatefulWidget {
const DashboardScreen({super.key});


@override
State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
int _index = 0;


final _pages = [
  const Center(child: Text('Home')),
  const Center(child: Text('Calendar')),
  const TasksScreen(), // ✅ REAL SCREEN
  const Center(child: Text('Assignments')),
];



@override
Widget build(BuildContext context) {
return Scaffold(
  appBar: AppBar(
    title: const Text('Dashboard'),
  ),
  body: _pages[_index],
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _index,
    onTap: (i) => setState(() => _index = i),

    // ✅ ADD THESE LINES
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,

    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Calendar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.checklist),
        label: 'Tasks',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Assignments',
      ),
    ],
  ),
);


}
}