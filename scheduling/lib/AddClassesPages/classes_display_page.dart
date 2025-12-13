import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_classes_page.dart'; // Import your Add Page
import 'package:scheduling/FirebaseServices/firestore_service.dart'; // Import your Service

// 1. THE DATA MODEL
// We keep this to make passing data to the card easier
class ClassModel {
  final String title;
  final String time;
  final String day;
  final Color color;
  final String location;
  final String lecturer;

  ClassModel({
    required this.title,
    required this.time,
    required this.day,
    required this.color,
    required this.location,
    required this.lecturer,
  });
}

class ClassesDisplayPage extends StatefulWidget {
  const ClassesDisplayPage({super.key});

  @override
  State<ClassesDisplayPage> createState() => _ClassesDisplayPageState();
}

class _ClassesDisplayPageState extends State<ClassesDisplayPage> {
  // We don't need the hardcoded List anymore!
  // The StreamBuilder will handle the data source.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed:
              () => Navigator.pop(context), // Or whatever nav logic you have
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                "Classes 📚",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Search and Add Button Row
              Row(
                children: [
                  const Icon(Icons.search, size: 28, color: Colors.black54),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the Add Classes Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddClassesPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A72FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Add Classes +",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. THE REAL-TIME LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Connect to the stream we created in FirestoreService
                  stream: FirestoreService().getClassesStream(),
                  builder: (context, snapshot) {
                    // Case 1: Waiting for connection or loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Case 2: Error
                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }

                    // Case 3: No data yet (The "Blank" state you asked for)
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No classes added yet.\nClick 'Add Classes +' to start!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    // Case 4: We have data! Let's build the list.
                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        // Get the raw data from Firestore document
                        final data = docs[index].data() as Map<String, dynamic>;

                        // Convert Firestore data to our ClassModel
                        // We handle potential missing keys safely
                        final classItem = ClassModel(
                          title: data['title'] ?? 'No Title',
                          // Combine start and end time for display
                          time: "${data['startTime']} - ${data['endTime']}",
                          // Join the list of days (e.g., ["Mon", "Wed"] -> "Mon, Wed")
                          day:
                              (data['days'] as List<dynamic>?)?.join(", ") ??
                              "",
                          // Convert the stored integer back to a Color object
                          color: Color(data['color'] ?? 0xFF4A72FF),
                          location: data['location'] ?? 'Unknown',
                          lecturer: data['lecturer'] ?? 'Unknown',
                        );

                        return ClassCardWidget(
                          classData: classItem,
                          onTap: () {
                            _showClassDetails(context, classItem);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Bar (Mock)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A72FF),
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Classes"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Folders"),
        ],
      ),
    );
  }

  // 3. POPUP DETAILS (Unchanged logic, just uses the data)
  void _showClassDetails(BuildContext context, ClassModel data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: data.color,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                _buildDetailRow(Icons.access_time, "${data.day}\n${data.time}"),
                const SizedBox(height: 20),

                _buildDetailRow(Icons.location_on_outlined, data.location),
                const SizedBox(height: 20),

                _buildDetailRow(Icons.person_outline, data.lecturer),
                const SizedBox(height: 40),

                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(
                          0.2,
                        ), // Slight transparency
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// 4. THE REUSABLE WIDGET (Unchanged)
class ClassCardWidget extends StatelessWidget {
  final ClassModel classData;
  final VoidCallback onTap;

  const ClassCardWidget({
    super.key,
    required this.classData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: classData.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classData.title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${classData.time}, ${classData.day}",
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
