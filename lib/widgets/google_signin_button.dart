import 'package:flutter/material.dart';
import 'package:taskfission_1/services/auth_service.dart';

class GoogleSignInButton extends StatelessWidget {
  GoogleSignInButton({super.key});

  final AuthService _auth = AuthService();

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      await _auth.signInWithGoogle();
      // AuthGate will redirect automatically
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Image.asset(
          'assets/google.png',
          height: 20,
        ),
        label: const Text('Continue with Google'),
        onPressed: () => _handleGoogleSignIn(context),
      ),
    );
  }
}
