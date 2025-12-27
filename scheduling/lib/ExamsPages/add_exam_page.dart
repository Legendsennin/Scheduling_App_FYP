import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:scheduling/FirebaseServices/firestore_service.dart'; // Check your path

class AddExamPage extends StatefulWidget {
  const AddExamPage({super.key});

  @override
  State<AddExamPage> createState() => _AddExamPageState();
}

class _AddExamPageState extends State<AddExamPage> {
  // --- STATE VARIABLES ---
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _topicsController = TextEditingController();
  final TextEditingController _seatController = TextEditingController();

  // Dropdown State
  String? _selectedSubject;
  int _selectedColor = 0xFF4A72FF; // Default Blue if no class selected

  // Date State
  DateTime _selectedDate = DateTime.now();

  // Time State (Start)
  int _hour = 9;
  String _minute = "00";
  String _amPm = "AM";

  // Loading state
  bool _isLoading = false;

  // Temp User ID (Must match what you used in Add Classes)
  final String tempUserId = "student_test_user_001";

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
                  "Add Exam 📝",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 1. SUBJECT DROPDOWN (Replaces old Text Field)
              _buildLabel("Select Subject"),
              const SizedBox(height: 10),
              _buildSubjectDropdown(),
              const SizedBox(height: 15),

              // 2. OTHER INPUTS
              _buildLabel("Location / Venue"),
              _buildTextField(_locationController, "e.g., Hall A"),
              const SizedBox(height: 15),

              _buildLabel("Seat Number"),
              _buildTextField(_seatController, "e.g., A-12"),
              const SizedBox(height: 15),

              _buildLabel("Topics / Notes"),
              _buildTextField(_topicsController, "e.g., Chapters 1-5"),
              const SizedBox(height: 25),

              // 3. DATE PICKER
              _buildLabel("Date"),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF4A72FF)),
                      const SizedBox(width: 15),
                      Text(
                        DateFormat('EEEE, d MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 4. TIME PICKER
              _buildLabel("Time"),
              const SizedBox(height: 10),
              Center(child: _buildTimeRow()),
              const SizedBox(height: 40),

              // 5. BUTTONS
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
                      onPressed: _isLoading ? null : _submitExam,
                      style: ElevatedButton.styleFrom(
                        // Dynamic Color based on Subject!
                        backgroundColor: Color(_selectedColor),
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

  // --- WIDGETS ---

  Widget _buildSubjectDropdown() {
    return StreamBuilder<QuerySnapshot>(
      // Fetches only MY classes
      stream: FirestoreService().getClassesStream(tempUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: LinearProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text("Error loading classes");
        }

        final docs = snapshot.data!.docs;
        
        // Helper to map Subject Name -> Color
        // We use this to update the UI color immediately when selected
        Map<String, int> colorMap = {};

        // Convert Docs to Dropdown Items
        List<DropdownMenuItem<String>> items = [];
        
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String title = data['title'] ?? 'Unknown Class';
          final int color = data['color'] ?? 0xFF4A72FF;

          colorMap[title] = color;

          items.add(
            DropdownMenuItem(
              value: title,
              child: Row(
                children: [
                  // Little Color Dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(title),
                ],
              ),
            ),
          );
        }

        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text("No classes found. Add a class first!"),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSubject,
              hint: const Text("Choose a class..."),
              isExpanded: true,
              items: items,
              onChanged: (val) {
                setState(() {
                  _selectedSubject = val;
                  // Auto-update color
                  if (val != null && colorMap.containsKey(val)) {
                    _selectedColor = colorMap[val]!;
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  // --- LOGIC ---

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(_selectedColor), // Matches subject color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitExam() async {
    // 1. Validation
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a subject first")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Format Time
      String formattedTime = "$_hour:$_minute $_amPm";

      // 3. Create Full DateTime (for sorting)
      int hour24 = _hour;
      if (_amPm == "PM" && _hour != 12) hour24 += 12;
      if (_amPm == "AM" && _hour == 12) hour24 = 0;

      DateTime fullDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour24,
        int.parse(_minute),
      );

      // 4. Call Service
      await FirestoreService().addExam(
        userId: tempUserId,
        subjectName: _selectedSubject!, 
        dateStr: DateFormat('dd/MM/yyyy').format(_selectedDate),
        timeStr: formattedTime,
        location: _locationController.text.trim(),
        topics: _topicsController.text.trim(),
        seatNumber: _seatController.text.trim(),
        fullDateTime: fullDateTime,
        colorValue: _selectedColor, // <--- SAVING THE CLASS COLOR
      );

      // 5. Success
      if (context.mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Exam added successfully!")),
        );
      }
    } catch (e) {
      print("Error: $e");
      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
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

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSpinner(
          value: _hour.toString(),
          onUp: () => setState(() => _hour = _hour == 12 ? 1 : _hour + 1),
          onDown: () => setState(() => _hour = _hour == 1 ? 12 : _hour - 1),
        ),
        const Text(
          " : ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        _buildSpinner(
          value: _minute,
          onUp: () => setState(() => _minute = _minute == "00" ? "30" : "00"),
          onDown: () => setState(() => _minute = _minute == "00" ? "30" : "00"),
        ),
        const SizedBox(width: 10),
        _buildSpinner(
          value: _amPm,
          width: 50,
          onUp: () => setState(() => _amPm = _amPm == "AM" ? "PM" : "AM"),
          onDown: () => setState(() => _amPm = _amPm == "AM" ? "PM" : "AM"),
        ),
      ],
    );
  }

  Widget _buildSpinner({
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
    double width = 50,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onUp,
          child: const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
        ),
        Container(
          width: width,
          height: 40,
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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