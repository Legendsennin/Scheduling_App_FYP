import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LoginAuthPages/homescreen.dart';
import 'LoginAuthPages/loginscreen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomePage(); // Replace with your authenticated home page
        } else {
          return const LoginPage(); // Replace with your login page
        }
      },
    );
  }
}
