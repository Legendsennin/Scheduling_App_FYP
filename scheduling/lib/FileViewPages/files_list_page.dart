import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:scheduling/FirebaseServices/storage_service.dart'; // Import Service
import 'file_upload_page.dart'; // Import Upload Page
import 'feature_utils.dart'; // Your provided utils file

class FilesListPage extends StatefulWidget {
  final String folderName;
  final String folderId; // REQUIRED: To know which folder to query

  const FilesListPage({
    super.key,
    required this.folderName,
    required this.folderId,
  });

  @override
  State<FilesListPage> createState() => _FilesListPageState();
}

class _FilesListPageState extends State<FilesListPage> {
  // Temp User ID
  final String userId = "student_test_user_001"; 
  // Search State
  String _searchKeyword = "";


  // --- OPEN FILE ---
  void _handleFileTap(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening File...")),
    );
    
    StorageService().openFile(data['url'], data['name']);
  }

  

  // 1. RENAME LOGIC (Updates the name in Firestore only)
  Future<void> _handleRename(String docId, String newName) async {
    try {
      await FirebaseFirestore.instance
          .collection('folders')
          .doc(widget.folderId)
          .collection('files')
          .doc(docId)
          .update({'name': newName}); // Only updates the display name
          
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Renamed to $newName")),
        );
      }
    } catch (e) {
      print("Error renaming: $e");
    }
  }

  // 2. DELETE LOGIC (Deletes from Storage AND Firestore)
  Future<void> _handleDelete(String docId, String storagePath) async {
    try {
      // Call your StorageService to delete both file and database entry
      await StorageService().deleteFile(widget.folderId, docId, storagePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File deleted")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting: $e")),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.folderName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        overlayColor: Colors.white,
        overlayOpacity: 0.6,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.cloud_upload, color: Colors.white),
            label: 'Upload File',
            backgroundColor: const Color(0xFF4A72FF),
            onTap: () {
              // Navigate to Upload Page with IDs
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileUploadPage(
                    folderId: widget.folderId,
                    userId: userId,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Row(
              children: [
                Text(
                  "Folders and Files 📂",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            
           // SEARCH BAR
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('folders')
                    .doc(widget.folderId)
                    .collection('files')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No files yet. Upload one!"));
                  }

                  

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final String docId = doc.id;

                      return _buildFileRow(data, docId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileRow(Map<String, dynamic> data, String docId) {
    String type = data['type'] ?? 'file';
    String fileName = data['name'] ?? 'Unknown';
    String storagePath = data['storagePath'] ?? ''; // Need this for deletion!

    // --- Icon Styling Logic ---
    IconData icon = Icons.insert_drive_file;
    Color iconColor = Colors.grey;
    Color bgColor = Colors.grey[100]!;

    if (type.contains('pdf')) {
      icon = Icons.picture_as_pdf;
      iconColor = const Color(0xFFFF7043);
      bgColor = const Color(0xFFFFEBEE);
    } else if (type.contains('mp4')) {
      icon = Icons.movie;
      iconColor = Colors.black87;
      bgColor = Colors.blue[50]!;
    } else if (['jpg', 'png', 'jpeg'].any((e) => type.contains(e))) {
      icon = Icons.image;
      iconColor = Colors.blue;
      bgColor = Colors.blue[50]!;
    }

    // --- The Row Widget ---
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        // Tap to Open
        onTap: () => _handleFileTap(data), 
        
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: const Color(0xFFF5F7FA),
        
        // Leading Icon
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        
        // File Info
        title: Text(fileName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(data['size'] ?? '', style: const TextStyle(fontSize: 12)),
        
        // --- THE 3-DOT MENU (From FeatureUtils) ---
        trailing: FeatureUtils.buildMoreMenu(
          onRename: () {
            // Show the standard rename dialog
            FeatureUtils.showRenameDialog(
              context, 
              fileName, // Current name
              (newName) {
                _handleRename(docId, newName); // Call our logic
              },
            );
          },
          onDelete: () {
            // Confirm delete (you could add a confirmation dialog here if you wanted)
            _handleDelete(docId, storagePath);
          },
        ),
      ),
    );
  }
}