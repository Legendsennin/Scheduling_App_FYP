import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduling/FirebaseServices/firestore_service.dart'; // Check path

// 1. DATA MODEL
class ExamModel {
  final String subject;
  final String date;
  final String time;
  final String location;
  final String topics;
  final String seatNumber;
  final DateTime fullDateTime;
  final int colorValue; // <--- NEW

  ExamModel({
    required this.subject,
    required this.date,
    required this.time,
    required this.location,
    required this.topics,
    required this.seatNumber,
    required this.fullDateTime,
    required this.colorValue, // <--- NEW
  });
}

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  final String tempUserId = "student_test_user_001"; // Must match add_exam_page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
                "Exams 📝",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Search & Add Button
              Row(
                children: [
                  const Icon(Icons.search, size: 28, color: Colors.black54),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add_exam');
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
                      "Add Exam +",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. THE REAL-TIME LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService().getExamsStream(tempUserId),
                  builder: (context, snapshot) {


                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No exams added yet.\nGood luck with your studies!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        // Map Firestore data to Model
                        final examItem = ExamModel(
                          subject: data['subject'] ?? 'No Subject',
                          date: data['date'] ?? '',
                          time: data['time'] ?? '',
                          location: data['location'] ?? 'Unknown',
                          topics: data['topics'] ?? '',
                          seatNumber: data['seatNumber'] ?? '',
                          // Parse Timestamp back to DateTime
                          fullDateTime: (data['fullDateTime'] as Timestamp).toDate(),
                          colorValue: data['colorValue'] ?? 0xFFFF7043, // Default to orange if missing
                        );

                        return ExamCardWidget(
                          examData: examItem,
                          onTap: () => _showExamDetails(context, examItem),
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
    );
  }

  // 3. POPUP DETAILS
  void _showExamDetails(BuildContext context, ExamModel data) {
    // We use a distinct color for Exams (e.g., Orange/Coral)
    const Color examCardColor = Color(0xFFFF7043); 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: examCardColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                _buildDetailRow(Icons.calendar_today, data.date),
                const SizedBox(height: 15),
                _buildDetailRow(Icons.access_time, data.time),
                const SizedBox(height: 15),
                _buildDetailRow(Icons.location_on_outlined, data.location),
                const SizedBox(height: 15),
                _buildDetailRow(Icons.chair, "Seat: ${data.seatNumber}"),
                const SizedBox(height: 15),
                _buildDetailRow(Icons.book, "Topics: ${data.topics}"),
                
                const SizedBox(height: 30),

                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
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
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text.isEmpty ? "N/A" : text,
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

// 4. REUSABLE CARD WIDGET
class ExamCardWidget extends StatelessWidget {
  final ExamModel examData;
  final VoidCallback onTap;

  const ExamCardWidget({
    super.key,
    required this.examData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic countdown text (optional feature)
    final daysLeft = examData.fullDateTime.difference(DateTime.now()).inDays;
    String statusText = daysLeft < 0 
        ? "Completed" 
        : daysLeft == 0 ? "Today!" : "in $daysLeft days";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(examData.colorValue), // Light orange background for cards
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  examData.subject,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${examData.date} • ${examData.time}",
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

