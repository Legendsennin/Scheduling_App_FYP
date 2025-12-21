import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  Stream<QuerySnapshot> _taskStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('dueDate')
        .snapshots();
  }

  bool _isOverdue(Timestamp dueDate) {
    return dueDate.toDate().isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _taskStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          final docs = snapshot.data!.docs;

          final due = <QueryDocumentSnapshot>[];
          final overdue = <QueryDocumentSnapshot>[];
          final completed = <QueryDocumentSnapshot>[];

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final bool isCompleted = data['completed'] ?? false;
            final Timestamp dueDate = data['dueDate'];

            if (isCompleted) {
              completed.add(doc);
            } else if (_isOverdue(dueDate)) {
              overdue.add(doc);
            } else {
              due.add(doc);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(context, 'Due', due),
              _buildSection(context, 'Overdue', overdue),
              _buildSection(context, 'Completed', completed, completedSection: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<QueryDocumentSnapshot> tasks, {
    bool completedSection = false,
  }) {
    if (tasks.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...tasks.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final Timestamp dueDate = data['dueDate'];

          return Card(
            child: ListTile(
              title: Text(data['title']),
              subtitle: Text(
                'Due: ${dueDate.toDate().day}/${dueDate.toDate().month}/${dueDate.toDate().year}',
              ),
              trailing: completedSection
                  ? const Icon(Icons.check, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () async {
                        await doc.reference.update({'completed': true});
                      },
                    ),
            ),
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}
