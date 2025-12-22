import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'files_list_page.dart'; // Ensure this matches your actual file name

// Mock Model for Folders
class FolderData {
  final String name;
  final String date;
  final Color color;
  final Color iconColor;

  FolderData(this.name, this.date, this.color, this.iconColor);
}

class FoldersGridPage extends StatefulWidget {
  const FoldersGridPage({super.key});

  @override
  State<FoldersGridPage> createState() => _FoldersGridPageState();
}

class _FoldersGridPageState extends State<FoldersGridPage> {
  // Mock Data (The Master List)
  final List<FolderData> _allFolders = [
    FolderData("OOP", "12/12/2025", const Color(0xFFE3F2FD), const Color(0xFF4285F4)),
    FolderData("English", "14/12/2025", const Color(0xFFFFF8E1), const Color(0xFFFFCA28)),
    FolderData("CAAL", "11/11/2025", const Color(0xFFFFEBEE), const Color(0xFFEF5350)),
    FolderData("Maths 3", "10/11/2025", const Color(0xFFE8F5E9), const Color(0xFF66BB6A)),
    FolderData("Business Fund", "10/11/2025", const Color(0xFFE3F2FD), const Color(0xFF4285F4)),
    FolderData("Software Testing", "10/11/2025", const Color(0xFFF3E5F5), const Color(0xFFAB47BC)),
  ];

  // The Display List (What shows on screen)
  List<FolderData> _filteredFolders = [];

  @override
  void initState() {
    super.initState();
    // Initially, the display list is the same as the master list
    _filteredFolders = _allFolders;
  }

  // Filter Function for searching specific folders/files
  void _runFilter(String enteredKeyword) {
    List<FolderData> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allFolders;
    } else {
      results = _allFolders
          .where((folder) =>
              folder.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Refresh the UI
    setState(() {
      _filteredFolders = results;
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
// Floating add button with two options: Upload File and Add New Folder
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row section for title and upload files n folder icons
            Row(
              children: [
                const Text(
                  "Folders and Files 📂",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E)),
                ),
                const SizedBox(width: 30),
                
              ],
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

            

            // GRID VIEW (Uses _filteredFolders now)
            Expanded(
              child: GridView.builder(
                itemCount: _filteredFolders.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  return _buildFolderCard(_filteredFolders[index]);
                },
              ),
            ),
          ],
        ),
      ),
      // Mock Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: const Color(0xFF4A72FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Classes"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Folders"),
        ],
      ),
    );
  }

//Widget design for how each folder card looks
  Widget _buildFolderCard(FolderData folder) {
    return GestureDetector(
      onTap: () {
        // NAVIGATE TO THE SECOND FILE
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FilesListPage(folderName: folder.name)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: folder.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.folder, color: folder.iconColor, size: 40),
                const Icon(Icons.more_vert, color: Colors.black54),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: folder.iconColor.withOpacity(0.8)),
                ),
                const SizedBox(height: 4),
                Text(folder.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}