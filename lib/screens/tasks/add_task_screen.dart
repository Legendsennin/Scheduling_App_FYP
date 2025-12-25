import 'package:flutter/material.dart';
import '../../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  String? selectedSubject;
  String? selectedType;
  DateTime? selectedDate;

  bool isLoading = false;

  final List<String> subjects = ['Software', 'Networking', 'AI'];
  final List<String> types = ['Task', 'Assignment', 'Quiz'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

void _saveTask() async {
  // 👇 2 lines ABOVE validation
  if (selectedSubject == null ||
      selectedType == null ||
      selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please complete all fields')),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    await TaskService().addTask(
      title: titleController.text.trim(),
      details: detailsController.text.trim(),
      subject: selectedSubject!,   // 🔴 ! is important
      type: selectedType!,         // 🔴 ! is important
      dueDate: selectedDate!,      // 🔴 ! is important
    );

    if (!mounted) return;
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedSubject,
              hint: const Text('Subject'),
              items: subjects
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                });
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedType,
              hint: const Text('Type'),
              items: types
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
            const SizedBox(height: 15),

            OutlinedButton(
              onPressed: _pickDate,
              child: Text(
                selectedDate == null
                    ? 'Pick Due Date'
                    : 'Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveTask,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
