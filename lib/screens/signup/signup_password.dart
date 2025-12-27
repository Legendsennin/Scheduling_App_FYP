import 'package:flutter/material.dart';
import 'signup_scaffold.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';

class SignupPassword extends StatefulWidget {
  final Map<String, dynamic> signupData;

  const SignupPassword({super.key, required this.signupData});

  @override
  State<SignupPassword> createState() => _SignupPasswordState();
}

class _SignupPasswordState extends State<SignupPassword> {
  final _passwordController = TextEditingController();

  void _finish() async {
    try {
      await AuthService().register(
        widget.signupData['email'],
        _passwordController.text,
        widget.signupData,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignupScaffold(
      step: 5,
      onContinue: _finish,
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
      ),
    );
  }
}
