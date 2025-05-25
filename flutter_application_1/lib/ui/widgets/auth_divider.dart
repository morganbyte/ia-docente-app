import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade400)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "o",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade400)),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}