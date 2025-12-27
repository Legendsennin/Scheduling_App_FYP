import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 

import 'package:scheduling/FirebaseServices/folder_service.dart'; // Import the service
import 'files_list_page.dart';
import 'feature_utils.dart'; // Your provided utils file

class FoldersGridPage extends StatefulWidget {
  const FoldersGridPage({super.key});

  @override
  State<FoldersGridPage> createState() => _FoldersGridPageState();
}

class _FoldersGridPageState extends State<FoldersGridPage> {
  // Service Instance
  final FolderService _folderService = FolderService();
  
  // Get current user (Make sure user is logged in before accessing this page)
 //final String userId = FirebaseAuth.instance.currentUser!.uid;

 // TEMPORARY: Hardcoded ID for testing since Login isn't ready
  final String userId = "student_test_user_001";

  // Search State
  String _searchKeyword = "";

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
      
      // FLOATING ACTION BUTTON
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        overlayColor: Colors.white,
        overlayOpacity: 0.6,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.note_add, color: Colors.white),
            label: 'Upload File',
            backgroundColor: const Color(0xFF4A72FF),
            onTap: () {
              Navigator.pushNamed(context, '/fileupload');
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.create_new_folder, color: Colors.white),
            label: 'Add New Folder',
            backgroundColor: const Color(0xFF4A72FF),
            onTap: () {
              // 1. OPEN DIALOG FROM UTILS
              FeatureUtils.showCreateFolderDialog(
                context, 
                // 2. HANDLE CALLBACK
                (name, colors) {
                  // 3. CALL FIRESTORE SERVICE
                  _folderService.createManualFolder(
                    userId, 
                    name, 
                    colors[0], // Background Color
                    colors[1]  // Icon Color
                  );
                }
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

            // STREAM BUILDER (Replaces local GridView)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _folderService.getUserFolders(userId),
                builder: (context, snapshot) {
                  // Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error State
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  // Filter Data based on Search
                  final docs = snapshot.data?.docs ?? [];
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchKeyword);
                  }).toList();

                  // Empty State
                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text("No folders found"));
                  }

                  return GridView.builder(
                    itemCount: filteredDocs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildFolderCard(filteredDocs[index]);
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

  // --- CARD WIDGET ---
  Widget _buildFolderCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String folderId = doc.id;
    final String name = data['name'] ?? 'Untitled';
    
    // Formatting Date
    String dateStr = "";
    if (data['createdAt'] != null) {
      Timestamp t = data['createdAt'];
      dateStr = DateFormat('dd/MM/yyyy').format(t.toDate());
    }

    // Recovering Colors from Integers
    Color bgColor = Color(data['colorValue'] ?? 0xFFE3F2FD);
    Color iconColor = Color(data['iconColorValue'] ?? 0xFF4285F4);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FilesListPage(
                  folderName: name,
                  folderId: folderId, // <--- ADD THIS
                )));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.folder, color: iconColor, size: 40),
                
                // POPUP MENU (From FeatureUtils)
                FeatureUtils.buildMoreMenu(
                  onRename: () {
                    FeatureUtils.showRenameDialog(
                      context, 
                      name, 
                      (newName) {
                        // Call Firestore Service
                        _folderService.renameFolder(folderId, newName);
                      }
                    );
                  },
                  onDelete: () {
                    // Call Firestore Service
                    _folderService.deleteFolder(folderId);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Deleted $name"))
                    );
                  },
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: iconColor.withOpacity(0.8)),
                ),
                const SizedBox(height: 4),
                Text(dateStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}