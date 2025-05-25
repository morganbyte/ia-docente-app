import 'package:flutter/material.dart';

class AuthInputFields extends StatelessWidget {
  final bool isLogin;
  final TextEditingController displayNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;

  const AuthInputFields({
    super.key,
    required this.isLogin,
    required this.displayNameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
  });

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: false,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLogin) ...[
          TextField(
            controller: displayNameCtrl,
            decoration: _inputStyle("Nombre"),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputStyle("Correo"),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: _inputStyle("Contraseña"),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}