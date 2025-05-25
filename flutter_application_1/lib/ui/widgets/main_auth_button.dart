import 'package:flutter/material.dart';

class MainAuthButton extends StatelessWidget {
  final bool loading;
  final bool isLogin;
  final VoidCallback onSubmit;
  final Color buttonColor;
  final Color buttonTextColor;

  const MainAuthButton({
    super.key,
    required this.loading,
    required this.isLogin,
    required this.onSubmit,
    required this.buttonColor,
    required this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(
                isLogin ? "Ingresar" : "Empezar",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}