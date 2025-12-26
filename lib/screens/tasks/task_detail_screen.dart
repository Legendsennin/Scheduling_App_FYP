import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot taskDoc;

  const TaskDetailScreen({super.key, required this.taskDoc});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController titleController;
  late TextEditingController detailsController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.taskDoc.data() as Map<String, dynamic>;

    titleController = TextEditingController(text: data['title']);
    detailsController = TextEditingController(text: data['details']);
  }

  Future<void> _updateTask() async {
    setState(() => isSaving = true);

    await widget.taskDoc.reference.update({
      'title': titleController.text.trim(),
      'details': detailsController.text.trim(),
    });

    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.taskDoc.reference.delete();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.taskDoc.data() as Map<String, dynamic>;
    final Timestamp dueDate = data['dueDate'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            Text('Subject: ${data['subject']}'),
            const SizedBox(height: 4),
            Text('Type: ${data['type']}'),
            const SizedBox(height: 4),
            Text(
              'Due Date: ${dueDate.toDate().day}/${dueDate.toDate().month}/${dueDate.toDate().year}',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _updateTask,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
