import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  bool loading = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = doc.data();
    nameCtrl.text = data?['name'] ?? '';
    emailCtrl.text = data?['email'] ?? '';
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    setState(() => loading = true);

    final ref = FirebaseStorage.instance
        .ref('profile_photos/${user!.uid}.jpg');

    await ref.putFile(File(img.path));
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'photoUrl': url});

    setState(() => loading = false);
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fields cannot be empty')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _uploadPhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Change Photo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
