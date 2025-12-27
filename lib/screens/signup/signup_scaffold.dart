import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScaffold extends StatelessWidget {
  final int step;
  final VoidCallback onContinue;
  final Widget child;

  const SignupScaffold({
    super.key,
    required this.step,
    required this.onContinue,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create account',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // 🔹 STEP INDICATOR
            Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index < step
                          ? const Color(0xFF6C63FF)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // 🔹 PAGE CONTENT (EMAIL / NAME / ETC)
            child,

            const Spacer(),

            // 🔹 CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text('Continue'),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 GOOGLE SIGN UP (NOW BELOW CONTINUE ✅)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Image.asset(
                  'assets/google.png',
                  height: 20,
                ),
                label: const Text('Continue with Google'),
                onPressed: () async {
                  try {
                    await AuthService().signInWithGoogle();
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Have an account? Log in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
