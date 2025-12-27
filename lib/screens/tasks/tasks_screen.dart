import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_task_screen.dart';
import 'task_detail_screen.dart';

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
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTaskScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Tasks'),
          ),
        ],
      ),
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
              _buildSection(context, 'Due', due, color: Colors.blue),
              _buildSection(context, 'Overdue', overdue, color: Colors.red),
              _buildSection(
                context,
                'Completed',
                completed,
                color: Colors.green,
                completedSection: true,
              ),
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
    required Color color,
    bool completedSection = false,
  }) {
    if (tasks.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Text(
                  tasks.length.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...tasks.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final Timestamp dueDate = data['dueDate'];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(taskDoc: doc),
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          if ((data['details'] ?? '').toString().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              data['details'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),
                          Text(
                            'Due: ${dueDate.toDate().day}/${dueDate.toDate().month}/${dueDate.toDate().year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    completedSection
                        ? const Icon(Icons.check_circle,
                            color: Colors.green)
                        : IconButton(
                            icon:
                                const Icon(Icons.check_circle_outline),
                            onPressed: () async {
                              await doc.reference
                                  .update({'completed': true});
                            },
                          ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 28),
      ],
    );
  }
}
