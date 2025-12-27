import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Reference to the 'classes' collection
  final CollectionReference classesCollection =
      FirebaseFirestore.instance.collection('classes');

  // Reference to the 'exams' collection
  final CollectionReference examsCollection =
      FirebaseFirestore.instance.collection('exams');

  // ===============================================================
  // SECTION A: CLASSES LOGIC
  // ===============================================================

  Future<void> addClass({
    required String userId,
    required String title,
    required String venue,
    required String lecturer,
    required List<String> days,
    required String startTime,
    required String endTime,
    required int colorValue,
  }) async {
    print("DEBUG: Starting to add class: $title");
    try {
      await classesCollection.add({
        'userId': userId, // <--- SAVING ID
        'title': title,
        'location': venue,
        'lecturer': lecturer,
        'days': days,
        'startTime': startTime,
        'endTime': endTime,
        'color': colorValue,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("DEBUG: SUCCESS! Class added.");
    } catch (e) {
      print("DEBUG: ERROR ADDING CLASS: $e");
    }
  }

  // UPDATED: Now filters by userId (like your exams do)
  Stream<QuerySnapshot> getClassesStream(String userId) {
    return classesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteClass(String docId) async {
    return classesCollection.doc(docId).delete();
  }

  // ===============================================================
  // SECTION B: EXAMS LOGIC (UPDATED)
  // ===============================================================

  // Updated to match your UI's naming convention exactly
  Future<void> addExam({
    required String userId,        // Added this
    required String subjectName,   // Changed from 'subject'
    required String dateStr,       // Changed from 'date'
    required String timeStr,       // Changed from 'time'
    required String location,
    required String topics,        // Changed from 'notes'
    required String seatNumber,    // Added this
    required DateTime fullDateTime,// Added this (useful for sorting!)
    required int colorValue, // <--- NEW: Save the class color
  }) async {
    print("DEBUG: --------------------");
    print("DEBUG: Adding exam for: $subjectName");

    try {
      await examsCollection.add({
        'userId': userId,
        'subject': subjectName,
        'date': dateStr,
        'time': timeStr,
        'location': location,
        'topics': topics,
        'seatNumber': seatNumber,
        'fullDateTime': fullDateTime, // Storing the actual DateTime object
        'colorValue': colorValue, // <--- SAVED
        'timestamp': FieldValue.serverTimestamp(), // Created at time
      });

      print("DEBUG: SUCCESS! Exam added to Firestore.");
      print("DEBUG: --------------------");
    } catch (e) {
      print("DEBUG: ERROR ADDING EXAM!");
      print("DEBUG: $e");
      print("DEBUG: --------------------");
    }
  }


  

 // FIXED: Now accepts the tempId to fix the error in exam_list_page
  Stream<QuerySnapshot> getExamsStream(String userId) {
    return examsCollection
        .where('userId', isEqualTo: userId) // Filters for your specific tempId
        .orderBy('fullDateTime', descending: false) // Sorts by upcoming exams
        .snapshots();}

  Future<void> deleteExam(String docId) async {
    return examsCollection.doc(docId).delete();
  }
}