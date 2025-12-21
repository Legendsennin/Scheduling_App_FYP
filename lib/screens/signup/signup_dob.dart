import 'package:flutter/material.dart';
import 'signup_gender.dart';
import 'signup_scaffold.dart';

class SignupDob extends StatefulWidget {
  final Map<String, dynamic> signupData;

  const SignupDob({super.key, required this.signupData});

  @override
  State<SignupDob> createState() => _SignupDobState();
}

class _SignupDobState extends State<SignupDob> {
  DateTime? dob;

  void _next() {
    if (dob == null) return;

    widget.signupData['dob'] = dob;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupGender(signupData: widget.signupData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignupScaffold(
      step: 3,
      onContinue: _next,
      child: ListTile(
        title: Text(dob == null
            ? 'Select date of birth'
            : dob!.toString().split(' ')[0]),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            initialDate: DateTime(2005),
          );
          if (picked != null) {
            setState(() => dob = picked);
          }
        },
      ),
    );
  }
}
