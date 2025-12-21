import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int step;

  const ProgressIndicatorWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final done = index < step;

        return Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor:
                  done ? const Color(0xFF6C63FF) : Colors.grey[300],
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (index != 4)
              Container(
                width: 24,
                height: 2,
                color: Colors.grey[300],
              ),
          ],
        );
      }),
    );
  }
}
