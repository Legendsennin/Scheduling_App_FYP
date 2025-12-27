import 'package:flutter/material.dart';
import 'package:taskfission_1/screens/signup/signup_email.dart';
import 'package:taskfission_1/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;

  Future<void> _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password required')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.login(_email.text.trim(), _password.text.trim());
      // ❌ NO NAVIGATOR HERE
      // AuthGate will redirect automatically
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 GOOGLE SIGN IN
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Image.asset(
                  'assets/google.png',
                  height: 20,
                ),
                label: const Text('Sign in with Google'),
                onPressed: _googleLogin,
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 CREATE ACCOUNT (RESTORED)
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupEmail(),
                    ),
                  );
                },
                child: const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
