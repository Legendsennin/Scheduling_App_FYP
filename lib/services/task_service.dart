import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;

  Future<void> addTask({
    required String title,
    required String details,
    required String subject,
    required String type,
    required DateTime dueDate,
  }) async {
    // 👇 2 lines ABOVE where user-based saving starts
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _db
        .collection('users')          // users
        .doc(user.uid)                // userUID
        .collection('tasks')          // tasks
        .add({
      'title': title,
      'details': details,
      'subject': subject,
      'type': type,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': FieldValue.serverTimestamp(),
      'completed': false, // ✅ ADD THIS LINE
    });
  }
}
