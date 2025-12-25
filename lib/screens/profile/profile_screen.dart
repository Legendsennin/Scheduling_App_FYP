import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../login_screen.dart';


import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
  return Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'You are not logged in',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Log in'),
          ),
        ],
      ),
    ),
  );
}


    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _shimmer();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _taskStats(user.uid),
                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: CircleAvatar(
                    key: ValueKey(data?['photoUrl']),
                    radius: 50,
                    backgroundImage: data?['photoUrl'] != null
                        ? CachedNetworkImageProvider(data!['photoUrl'])
                        : null,
                    child: data?['photoUrl'] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  data?['name'] ?? 'No Name',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data?['email'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
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

                const Spacer(),

                OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Log out',
                      style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content:
                            const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 📊 TASK STATS
  Widget _taskStats(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _statsShimmer();

        final docs = snapshot.data!.docs;
        final done = docs.where((e) => e['isDone'] == true).length;
        final pending = docs.where((e) => e['isDone'] == false).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem(done.toString(), 'Task Done'),
            _statItem(pending.toString(), 'Task Pending'),
          ],
        );
      },
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _statsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(width: 80, height: 40, color: Colors.white),
          Container(width: 80, height: 40, color: Colors.white),
        ],
      ),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(radius: 50, backgroundColor: Colors.white),
          const SizedBox(height: 20),
          Container(height: 16, width: 120, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 14, width: 160, color: Colors.white),
        ],
      ),
    );
  }
}
