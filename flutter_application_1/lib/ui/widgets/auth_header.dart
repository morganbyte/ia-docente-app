import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final bool isLogin;
  final Color buttonColor; 

  const AuthHeader({
    super.key,
    required this.isLogin,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.star, color: Colors.black, size: 20),
        ),
        const SizedBox(height: 24),
        Text(
          isLogin ? "Bienvenido a EducaPro" : "Bienvenido a EducaPro",
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLogin
              ? "Ingresa los siguientes campos para iniciar sesión"
              : "Crea una cuenta, tomará unos segundos. Ingresa los siguientes campos",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}