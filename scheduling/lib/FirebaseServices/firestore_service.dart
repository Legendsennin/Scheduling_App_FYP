/*This file will handle two main jobs:

Writing: Taking your form inputs (Title, Time, Color, etc.) and converting them into a format Firestore understands (JSON).

Reading: Listening to the database and giving the data back to your app as a real-time Stream.*/
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Reference to the 'classes' collection in Firestore
  final CollectionReference classesCollection = FirebaseFirestore.instance
      .collection('classes');

  // 1. ADD CLASS (Create)
  /*Future<void> addClass({
    required String title,
    required String venue,
    required String lecturer,
    required List<String> days,
    required String startTime,
    required String endTime,
    required int colorValue, // We store color as an integer (e.g., 0xFF4A72FF)
  }) async {
    // Create a "Map" (JSON) to send to Firestore
    // We combine days and times into a single string for display if needed,
    // or store them separately to process later.
    await classesCollection.add({
      'title': title,
      'location': venue,
      'lecturer': lecturer,
      'days': days, // Stores as an array ["Mon", "Wed"]
      'startTime': startTime, // Stores as "10:00 AM"
      'endTime': endTime, // Stores as "11:00 AM"
      'color': colorValue, // Stores the integer value of the color
      'timestamp': FieldValue.serverTimestamp(), // Good for sorting by "newest"
    });
  }*/

  Future<void> addClass({
    required String title,
    required String venue,
    required String lecturer,
    required List<String> days,
    required String startTime,
    required String endTime,
    required int colorValue,
  }) async {
    // 1. Trace: Print this when the function starts
    print("DEBUG: --------------------");
    print("DEBUG: Starting to add class: $title");

    try {
      // 2. The risky part: talking to the database
      await classesCollection.add({
        'title': title,
        'location': venue,
        'lecturer': lecturer,
        'days': days,
        'startTime': startTime,
        'endTime': endTime,
        'color': colorValue,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Trace: If we get here, it worked!
      print("DEBUG: SUCCESS! Class added to Firestore.");
      print("DEBUG: --------------------");
    } catch (e) {
      // 4. Trace: If it crashed, this catches the error 'e' and prints it
      print("DEBUG: ERROR OCCURRED!");
      print("DEBUG: The error message is: $e");
      print("DEBUG: --------------------");
    }
  }

  // 2. GET CLASSES (Read)
  // We return a Stream so the app updates automatically
  Stream<QuerySnapshot> getClassesStream() {
    // You can order by 'timestamp' descending to show newest added first
    return classesCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // 3. DELETE CLASS (Optional helper)
  Future<void> deleteClass(String docId) async {
    return classesCollection.doc(docId).delete();
  }
}
