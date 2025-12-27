import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- NEW IMPORT
import '/FirebaseServices/firestore_service.dart';
import 'package:scheduling/FirebaseServices/folder_service.dart'; // <--- NEW IMPORT (Check path matches your project)

class AddClassesPage extends StatefulWidget {
  const AddClassesPage({super.key});

  @override
  State<AddClassesPage> createState() => _AddClassesPageState();
}

class _AddClassesPageState extends State<AddClassesPage> {
  // --- NEW FEATURE: AUTO-CREATE FOLDER (FIXED) ---
                    // 1. Define the temporary ID to match FoldersGridPage
            final String tempUserId = "student_test_user_001"; 


  
  // --- STATE VARIABLES ---
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();

  // Days
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _selectedDays = ['Mon'];

  // Time State (Start)
  int _startHour = 12;
  String _startMinute = "00";
  String _startAmPm = "AM";

  // Time State (End)
  int _endHour = 1;
  String _endMinute = "00";
  String _endAmPm = "PM";

  // Color Picker State
  Color _selectedColor = const Color(0xFFF06292);
  final List<Color> _availableColors = [
    const Color(0xFFF06292),
    const Color(0xFF000000),
    const Color(0xFF9575CD),
    const Color(0xFFFF4081),
    const Color(0xFF673AB7),
    const Color(0xFFE1BEE7),
    const Color(0xFFFFC107),
    const Color(0xFFFF8A65),
    const Color(0xFFFF3D00),
    const Color(0xFFFF7043),
  ];

  // Loading state
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Center(
                child: Text(
                  "Add Class 📚",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Inputs
              _buildLabel("Subject Name"),
              _buildTextField(_subjectController),
              const SizedBox(height: 15),

              _buildLabel("Venue"),
              _buildTextField(_venueController),
              const SizedBox(height: 15),

              _buildLabel("Lecturer"),
              _buildTextField(_lecturerController),
              const SizedBox(height: 25),

              // Days
              _buildLabel("Days"),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _days.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(day);
                        } else {
                          _selectedDays.add(day);
                        }
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          else
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                        border: isSelected
                            ? Border.all(
                                color: Colors.lightBlueAccent,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),

              // Time Pickers
              _buildLabel("Time"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeColumn("START", true),
                  _buildTimeColumn("END", false),
                ],
              ),
              const SizedBox(height: 25),

              // Color Picker
              const Center(
                child: Text(
                  "Pick Color",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableColors.map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == color
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5CAE9),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              // A. Basic Validation
                              if (_subjectController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter a subject name"),
                                  ),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              try {
                                // B. Format Data
                                String formatStart =
                                    "$_startHour:$_startMinute $_startAmPm";
                                String formatEnd =
                                    "$_endHour:$_endMinute $_endAmPm";

                                // C. Call Firestore (Save Class)
                                await FirestoreService().addClass(
                                  userId: tempUserId,
                                  title: _subjectController.text,
                                  venue: _venueController.text,
                                  lecturer: _lecturerController.text,
                                  days: _selectedDays,
                                  startTime: formatStart,
                                  endTime: formatEnd,
                                  colorValue: _selectedColor.value,
                                );

                                

// 2. Call the service directly using the temp ID
await FolderService().createFolderForClass(
  tempUserId,
  _subjectController.text, 
  _selectedColor.value,
);

print("Auto-folder created for ${_subjectController.text}");
                                // D. Close Page
                                if (context.mounted) {
                                  setState(() => _isLoading = false);
                                  Navigator.pop(context);
                                  
                                  // Optional: Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Class added & Folder created!")),
                                  );
                                }
                              } catch (e) {
                                // Error Handling
                                print("Error adding class: $e");
                                if (context.mounted) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A72FF),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Confirm",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String label, bool isStart) {
    int hour = isStart ? _startHour : _endHour;
    String minute = isStart ? _startMinute : _endMinute;
    String amPm = isStart ? _startAmPm : _endAmPm;

    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildSpinner(
              value: hour.toString(),
              onUp: () => setState(() {
                if (isStart) {
                  _startHour = _startHour == 12 ? 1 : _startHour + 1;
                } else {
                  _endHour = _endHour == 12 ? 1 : _endHour + 1;
                }
              }),
              onDown: () => setState(() {
                if (isStart) {
                  _startHour = _startHour == 1 ? 12 : _startHour - 1;
                } else {
                  _endHour = _endHour == 1 ? 12 : _endHour - 1;
                }
              }),
            ),
            const Text(
              " : ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildSpinner(
              value: minute,
              onUp: () => setState(() {
                if (isStart)
                  _startMinute = _startMinute == "00" ? "30" : "00";
                else
                  _endMinute = _endMinute == "00" ? "30" : "00";
              }),
              onDown: () => setState(() {
                if (isStart)
                  _startMinute = _startMinute == "00" ? "30" : "00";
                else
                  _endMinute = _endMinute == "00" ? "30" : "00";
              }),
            ),
            const SizedBox(width: 10),
            _buildSpinner(
              value: amPm,
              width: 50,
              onUp: () => setState(() {
                if (isStart)
                  _startAmPm = _startAmPm == "AM" ? "PM" : "AM";
                else
                  _endAmPm = _endAmPm == "AM" ? "PM" : "AM";
              }),
              onDown: () => setState(() {
                if (isStart)
                  _startAmPm = _startAmPm == "AM" ? "PM" : "AM";
                else
                  _endAmPm = _endAmPm == "AM" ? "PM" : "AM";
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpinner({
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
    double width = 40,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onUp,
          child: const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
        ),
        Container(
          width: width,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 2),
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        InkWell(
          onTap: onDown,
          child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ),
      ],
    );
  }
}