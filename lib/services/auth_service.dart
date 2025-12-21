import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔍 Check if email already exists (USED IN signup_email.dart)
  Future<void> checkEmailExists(String email) async {
    final methods = await _auth.fetchSignInMethodsForEmail(email);

    if (methods.isNotEmpty) {
      throw Exception('Email already in use');
    }
  }

  /// 📝 Register new user (USED IN signup_password.dart)
  Future<void> register(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Save profile to Firestore
      await _db.collection('users').doc(user.uid).set({
        'email': email,
        'name': userData['name'],
        'dob': userData['dob'],
        'gender': userData['gender'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send verification email
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  /// 🔐 Login (USED IN login_screen.dart)
  Future<void> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        throw Exception('Please verify your email before logging in');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
