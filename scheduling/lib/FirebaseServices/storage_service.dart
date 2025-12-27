import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. UPLOAD SINGLE FILE
  Future<void> uploadFile({
  required String userId,
  required String folderId,
  required PlatformFile file,
}) async {
  // CLEAN THE NAME: Remove spaces and symbols
  // "Lecture #1.pdf" -> "Lecture_1.pdf"
  String safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

  final path = 'users/$userId/$folderId/$safeName'; // Use safeName here
  final fileRef = _storage.ref().child(path);

  File fileOnDevice = File(file.path!);
  
  // Wait for upload...
  await fileRef.putFile(fileOnDevice);

  // ... then get URL
  final downloadUrl = await fileRef.getDownloadURL();

  // Save to Firestore using the original name (for display) 
  // but the safe URL
  await _firestore
      .collection('folders')
      .doc(folderId)
      .collection('files')
      .add({
    'name': file.name, // Display Name (Original)
    'safeName': safeName, // Storage Name
    'url': downloadUrl,
    'type': file.extension ?? 'file',
    'size': _formatBytes(file.size),
    'createdAt': FieldValue.serverTimestamp(),
    'storagePath': path,
  });
}

  // 2. OPEN FILE (Download -> Temp -> Native Viewer)
  Future<void> openFile(String url, String fileName) async {
    try {
      // A. Find a temp location on the phone
      final tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/$fileName');

      // B. Download the file bytes
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // C. Write bytes to the temp file
        await tempFile.writeAsBytes(response.bodyBytes);

        // D. Open with Native Android App
        final result = await OpenFilex.open(tempFile.path);
        print("Open result: ${result.type}");
      } else {
        print("Download failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error opening file: $e");
    }
  }

  // 3. DELETE FILE
  Future<void> deleteFile(String folderId, String docId, String storagePath) async {
    // Delete from Firestore
    await _firestore
        .collection('folders')
        .doc(folderId)
        .collection('files')
        .doc(docId)
        .delete();

    // Delete from Storage Bucket
    await _storage.ref().child(storagePath).delete();
  }

  // Helper: Convert bytes to readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
}