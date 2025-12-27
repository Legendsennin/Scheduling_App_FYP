//I moved all the UI logic (Dialogs, TextFields, Color Picker, Popup Menu) into this single file. I also moved the folderColors list here so both pages use the exact same colors.

import 'package:flutter/material.dart';

class FeatureUtils {
  // 1. Shared Color Palette
  static final List<List<Color>> folderColors = [
    [const Color(0xFFE3F2FD), const Color(0xFF4285F4)], // Blue
    [const Color(0xFFFFF8E1), const Color(0xFFFFCA28)], // Amber
    [const Color(0xFFFFEBEE), const Color(0xFFEF5350)], // Red
    [const Color(0xFFE8F5E9), const Color(0xFF66BB6A)], // Green
    [const Color(0xFFF3E5F5), const Color(0xFFAB47BC)], // Purple
  ];

  // 2. Create Folder Dialog
  static void showCreateFolderDialog(
    BuildContext context,
    Function(String name, List<Color> colors) onConfirm,
  ) {
    final TextEditingController folderNameController = TextEditingController();
    int selectedColorIndex = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("New Folder"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: folderNameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Enter folder name",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Select Color", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(folderColors.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setStateDialog(() => selectedColorIndex = index);
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: folderColors[index][0],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColorIndex == index
                                  ? const Color(0xFF4A72FF)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: selectedColorIndex == index
                              ? Icon(Icons.check, size: 20, color: folderColors[index][1])
                              : null,
                        ),
                      );
                    }),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A72FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (folderNameController.text.isNotEmpty) {
                      onConfirm(folderNameController.text, folderColors[selectedColorIndex]);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Create", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 3. Rename Dialog
  static void showRenameDialog(
    BuildContext context,
    String currentName,
    Function(String newName) onConfirm,
  ) {
    final TextEditingController renameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Rename"),
          content: TextField(
            controller: renameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter new name",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A72FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (renameController.text.isNotEmpty) {
                  onConfirm(renameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 4. The 3-Dot Menu
  static Widget buildMoreMenu({
    required VoidCallback onRename,
    required VoidCallback onDelete,
  }) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      onSelected: (value) {
        if (value == 'rename') onRename();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: Colors.black54),
              SizedBox(width: 10),
              Text('Rename'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}