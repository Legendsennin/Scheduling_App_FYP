import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔍 Check if email already exists
  Future<void> checkEmailExists(String email) async {
    final methods = await _auth.fetchSignInMethodsForEmail(email);
    if (methods.isNotEmpty) {
      throw Exception('Email already in use');
    }
  }

  /// 📝 Register new user
  Future<void> register(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Failed to create user');
    }

    await _db.collection('users').doc(user.uid).set({
      'email': email,
      'name': userData['name'],
      'dob': userData['dob'],
      'gender': userData['gender'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await user.sendEmailVerification();
  }

  /// 🔐 EMAIL LOGIN
  Future<void> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!credential.user!.emailVerified) {
      throw Exception('Please verify your email before logging in');
    }
  }

  /// 🔑 GOOGLE LOGIN (🔥 THIS WAS MISSING)
  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _auth.signInWithCredential(credential);

    final user = userCredential.user;
    if (user == null) return;

    // Create Firestore profile if first time
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
