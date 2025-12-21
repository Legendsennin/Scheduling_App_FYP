import 'package:flutter/material.dart';
import 'progress_indicator.dart';

class SignupScaffold extends StatelessWidget {
  final int step;
  final Widget child;
  final VoidCallback onContinue;

  const SignupScaffold({
    super.key,
    required this.step,
    required this.child,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ProgressIndicatorWidget(step: step),

              const SizedBox(height: 40),

              Expanded(child: child),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 12),

              // Google sign up on EVERY page
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Sign up with Google'),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Have an account? Log in',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
