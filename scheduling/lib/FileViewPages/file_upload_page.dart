import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import File Picker
import 'package:scheduling/FirebaseServices/storage_service.dart'; // Import your Service

class FileUploadPage extends StatefulWidget {
  final String folderId;
  final String userId;

  const FileUploadPage({
    super.key, 
    required this.folderId, 
    required this.userId
  });

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  // Store actual PlatformFiles here
  List<PlatformFile> _pickedFiles = [];
  bool _isUploading = false;

  // 1. PICK FILES FUNCTION
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any, // Allows PDF, Images, Videos, etc.
    );

    if (result != null) {
      setState(() {
        _pickedFiles.addAll(result.files);
      });
    }
  }

  // 2. UPLOAD FUNCTION
  Future<void> _uploadAllFiles() async {
    if (_pickedFiles.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      // Loop through all staged files and upload one by one
      for (var file in _pickedFiles) {
        await StorageService().uploadFile(
          userId: widget.userId,
          folderId: widget.folderId,
          file: file,
        );
      }
      
      // Success: Go back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All files uploaded successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Upload Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Upload", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Media Upload",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // DROP ZONE (Now clickable)
              GestureDetector(
                onTap: _pickFiles, // Click anywhere to pick
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4A72FF).withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A72FF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.cloud_upload_outlined,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Tap to browse files",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // FILES LIST
              Expanded(
                child: ListView.separated(
                  itemCount: _pickedFiles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    return _buildFileItem(_pickedFiles[index]);
                  },
                ),
              ),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadAllFiles,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A72FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    // Determine icon based on extension
    IconData icon = Icons.insert_drive_file;
    Color color = Colors.grey;
    if (file.extension == 'pdf') {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (['jpg', 'png', 'jpeg'].contains(file.extension)) {
      icon = Icons.image;
      color = Colors.blue;
    } else if (['mp4', 'mov'].contains(file.extension)) {
      icon = Icons.movie;
      color = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${(file.size / 1024).toStringAsFixed(1)} KB",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
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