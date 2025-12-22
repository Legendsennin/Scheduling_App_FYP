import 'package:flutter/material.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  // --- MOCK STATE ---
  // In the real app, this list will fill up when user picks files
  final List<Map<String, String>> _pickedFiles = [
    {
      "name": "Lecture 10.pdf",
      "size": "5.3MB",
      "type": "pdf",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Upload",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              const Text(
                "Media Upload",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                "Add your documents here, and you can upload up to 5 files max",
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 30),

              // 1. THE "DROP ZONE" (Blue Dashed Area)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FF), // Very light blue bg
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4A72FF).withOpacity(0.5), // Blue border
                    width: 1.5,
                    style: BorderStyle.solid, // (Flutter needs a package for dashed borders, solid is standard)
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The Blue Folder Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A72FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Click on the button below to upload your files",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    
                    // "Browse Files" Button
                    OutlinedButton(
                      onPressed: () {
                        // Logic to open File Picker
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4A72FF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      ),
                      child: const Text(
                        "Browse files",
                        style: TextStyle(color: Color(0xFF4A72FF), fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. THE SELECTED FILES LIST
              Expanded(
                child: ListView.separated(
                  itemCount: _pickedFiles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final file = _pickedFiles[index];
                    return _buildFileItem(file);
                  },
                ),
              ),

              // 3. THE SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A72FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the "Lecture 10.pdf" card
  Widget _buildFileItem(Map<String, String> file) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE), // Light Red for PDF
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Color(0xFFFF7043), size: 24),
          ),
          const SizedBox(width: 15),
          
          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file["name"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  file["size"]!,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // Close Button
          GestureDetector(
            onTap: () {
              // Logic to remove file from list
              setState(() {
                _pickedFiles.remove(file);
              });
            },
            child: const Icon(Icons.cancel, color: Colors.grey),
          )
        ],
      ),
    );
  }
}