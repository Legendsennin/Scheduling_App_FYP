import 'package:flutter/material.dart';
import 'signup_name.dart';
import 'signup_scaffold.dart';
import '../../services/auth_service.dart';

class SignupEmail extends StatefulWidget {
  const SignupEmail({super.key});

  @override
  State<SignupEmail> createState() => _SignupEmailState();
}

class _SignupEmailState extends State<SignupEmail> {
  final _emailController = TextEditingController();

  void _next() async {
    try {
      await AuthService().checkEmailExists(_emailController.text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignupName(
            signupData: {'email': _emailController.text},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignupScaffold(
      step: 1,
      onContinue: _next,
      child: TextField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
    );
  }
}
