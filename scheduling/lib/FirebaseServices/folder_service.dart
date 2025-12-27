import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FolderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _folders => _firestore.collection('folders');

  // 1. AUTO-CREATE: Use this when a user adds a class to their schedule
  // Updated: Now requires 'classColorInt' to match the folder color to the class
  Future<void> createFolderForClass(String userId, String className, int classColorInt) async {
    
    // Safety: Trim whitespace to prevent "Math" and "Math " being different folders
    final String cleanName = className.trim(); 

    // Check for duplicates
    final existing = await _folders
        .where('userId', isEqualTo: userId)
        .where('name', isEqualTo: cleanName)
        .get();

    if (existing.docs.isEmpty) {
      // Logic: Use the class color for the Icon, and a light version for Background
      Color mainColor = Color(classColorInt);
      int backgroundColorInt = mainColor.withOpacity(0.2).value; 

      await _folders.add({
        'name': cleanName,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'class', 
        // Save the calculated colors
        'colorValue': backgroundColorInt, 
        'iconColorValue': classColorInt, 
      });
    }
  }

  // 2. MANUAL CREATE: Use this for the "Add Folder" button
  Future<void> createManualFolder(String userId, String name, Color bg, Color icon) async {
    await _folders.add({
      'name': name.trim(), // Good practice to trim manual names too
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'personal',
      // Convert Color to Integer for Firestore storage
      'colorValue': bg.value,      
      'iconColorValue': icon.value, 
    });
  }

  // 3. READ: Get the stream of folders
  Stream<QuerySnapshot> getUserFolders(String userId) {
    return _folders
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 4. UPDATE: Rename
  Future<void> renameFolder(String folderId, String newName) async {
    await _folders.doc(folderId).update({'name': newName.trim()});
  }

  // 5. DELETE
  Future<void> deleteFolder(String folderId) async {
    await _folders.doc(folderId).delete();
  }

  // 6. SYNC: Check all classes and create missing folders
  // MOVED INSIDE THE CLASS
  Future<void> syncClassFolders(String userId) async {
    // A. Get all CLasses for this user
    final classesSnapshot = await _firestore
        .collection('classes') 
        .where('userId', isEqualTo: userId)
        .get();

    // B. Loop through each class
    for (var doc in classesSnapshot.docs) {
      final data = doc.data();
      final String className = data['title'] ?? data['subjectName'] ?? 'Unknown';
      
      // Attempt to get color, default to Blue (0xFF4285F4) if missing
      final int classColor = data['color'] ?? 0xFF4285F4;

      if (className != 'Unknown') {
        // C. Reuse our existing function (Updated to pass the color)
        await createFolderForClass(userId, className, classColor);
      }
    }
  }
}