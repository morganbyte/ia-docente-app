import 'package:flutter/material.dart';

class AuthToggleText extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const AuthToggleText({
    super.key,
    required this.isLogin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Text(
            isLogin ? "¿Aún no tienes cuenta?. " : "Si ya tienes una cuenta. ",
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          GestureDetector(
            onTap: onToggle,
            child: const Text(
              "...", 
              style: TextStyle(
                color: Color(0xFFf6f343),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
