import 'package:flutter/material.dart';
import 'signup_dob.dart';
import 'signup_scaffold.dart';

class SignupName extends StatefulWidget {
  final Map<String, dynamic> signupData;

  const SignupName({super.key, required this.signupData});

  @override
  State<SignupName> createState() => _SignupNameState();
}

class _SignupNameState extends State<SignupName> {
  final _nameController = TextEditingController();

  void _next() {
    widget.signupData['name'] = _nameController.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupDob(signupData: widget.signupData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignupScaffold(
      step: 2,
      onContinue: _next,
      child: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Full name'),
      ),
    );
  }
}
