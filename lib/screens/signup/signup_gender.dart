import 'package:flutter/material.dart';
import 'signup_password.dart';
import 'signup_scaffold.dart';

class SignupGender extends StatefulWidget {
  final Map<String, dynamic> signupData;

  const SignupGender({super.key, required this.signupData});

  @override
  State<SignupGender> createState() => _SignupGenderState();
}

class _SignupGenderState extends State<SignupGender> {
  String? gender;

  void _next() {
    if (gender == null) return;

    widget.signupData['gender'] = gender;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupPassword(signupData: widget.signupData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignupScaffold(
      step: 4,
      onContinue: _next,
      child: DropdownButtonFormField<String>(
        value: gender,
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
        ],
        onChanged: (value) => setState(() => gender = value),
        decoration: const InputDecoration(labelText: 'Gender'),
      ),
    );
  }
}
