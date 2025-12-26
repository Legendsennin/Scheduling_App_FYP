import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Stream<Map<String, int>> _taskStatsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .snapshots()
        .map((snapshot) {
      int done = 0;
      int pending = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final completed = data['completed'] ?? false;

        if (completed) {
          done++;
        } else {
          pending++;
        }
      }

      return {
        'done': done,
        'pending': pending,
      };
    });
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Log in'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 🔹 PROFILE IMAGE
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),

            const SizedBox(height: 16),

            Text(
              user.displayName ?? 'Student',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              user.email ?? '',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            // 🔹 EDIT PROFILE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade50,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
              child: const Text('Edit profile'),
            ),

            const SizedBox(height: 24),

            // 🔹 TASK STATS
            StreamBuilder<Map<String, int>>(
              stream: _taskStatsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final done = snapshot.data!['done']!;
                final pending = snapshot.data!['pending']!;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(count: done, label: 'Task Done'),
                    _StatCard(count: pending, label: 'Task Pending'),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // 🔹 NAVIGATION BOX (ADDED)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _NavTile(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {},
                  ),
                  _NavTile(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  _NavTile(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  _NavTile(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 🔹 CENTER LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;

  const _StatCard({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
