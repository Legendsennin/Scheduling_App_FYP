import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_screen.dart';

class SignupVerifyScreen extends StatelessWidget {
  const SignupVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 80,
              color: Color(0xFF6C63FF),
            ),
            const SizedBox(height: 24),

            const Text(
              'Verify your email',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              'We have sent a verification email to your address. '
              'Please verify before logging in.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                await user?.reload();

                if (user != null && user.emailVerified) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (_) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email not verified yet'),
                    ),
                  );
                }
              },
              child: const Text('I have verified'),
            ),

            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser
                    ?.sendEmailVerification();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification email resent'),
                  ),
                );
              },
              child: const Text('Resend email'),
            ),
          ],
        ),
      ),
    );
  }
}
