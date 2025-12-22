import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// Mock Model for Files
class FileData {
  final String name;
  final String date;
  final String type; // 'pdf', 'video'

  FileData(this.name, this.date, this.type);
}

class FilesListPage extends StatefulWidget {
  final String folderName;

  const FilesListPage({super.key, required this.folderName});

  @override
  State<FilesListPage> createState() => _FilesListPageState();
}

class _FilesListPageState extends State<FilesListPage> {
  // Mock Files Data (The Master List)
  final List<FileData> _allFiles = [
    FileData("Lecture 1", "Modified 29 sep 2022", "pdf"),
    FileData("Lecture 2", "Modified 29 sep 2022", "pdf"),
    FileData("Lecture 3.pdf", "Modified 29 sep 2022", "pdf"),
    FileData("Lecture 4 Video.mp4", "Modified 29 sep 2022", "video"),
    FileData("Lecture 5.pdf", "Modified 29 sep 2022", "pdf"),
  ];

  // The Display List
  List<FileData> _filteredFiles = [];

  @override
  void initState() {
    super.initState();
    // Initialize display list with all files
    _filteredFiles = _allFiles;
  }

  // Filter Function for searching specific folders/files
  void _runFilter(String enteredKeyword) {
    List<FileData> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allFiles;
    } else {
      results = _allFiles
          .where((file) =>
              file.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredFiles = results;
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title (Using widget.folderName because we are in a State class)
            Text(
              "${widget.folderName} 📂",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              onChanged: (value) => _runFilter(value), // Calls filter logic
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

           

            Text(widget.folderName,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 10),

            // THE FILE LIST (Uses _filteredFiles)
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFiles.length,
                itemBuilder: (context, index) {
                  return _buildFileRow(_filteredFiles[index]);
                },
              ),
            ),
          ],
        ),
      ),
      /*// Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Future logic for Upload Sheet
        },
        backgroundColor: const Color(0xFF4A72FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),*/

//Floating Add button with multiple options (upload file, add folder)
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
// Navigate to the Upload Page
                    Navigator.pushNamed(context, '/fileupload');            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.create_new_folder, color: Colors.white),
            label: 'Add New Folder',
            backgroundColor: const Color(0xFF4A72FF),
            onTap: () {
              // Logic for New Folder
            },
          ),
        ],
      )
    );
  }

//Widget design for each file row looks
  Widget _buildFileRow(FileData file) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    if (file.type == 'video') {
      icon = Icons.movie;
      iconColor = Colors.black54;
      bgColor = Colors.grey[200]!;
    } else {
      icon = Icons.picture_as_pdf;
      iconColor = const Color(0xFFFF7043);
      bgColor = const Color(0xFFFFEBEE);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: const Color(0xFFF5F7FA),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          file.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.star, size: 12, color: Color(0xFF4A72FF)),
            const SizedBox(width: 5),
            Text(file.date, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.more_horiz, color: Colors.blue),
      ),
    );
  }
}