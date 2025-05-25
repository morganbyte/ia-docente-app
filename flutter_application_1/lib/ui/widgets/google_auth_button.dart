import 'package:flutter/material.dart';

class GoogleAuthButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onGoogleLogin;
  final Color googleButtonColor;

  const GoogleAuthButton({
    super.key,
    required this.loading,
    required this.onGoogleLogin,
    required this.googleButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onGoogleLogin,
        icon: const Icon(Icons.g_mobiledata, size: 24),
        label: const Text(
          "Continuar con Google",
          style: TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: googleButtonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}