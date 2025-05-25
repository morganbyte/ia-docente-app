import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_colors.dart'; 

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textDark, 
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textDark, 
            ),
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight, 
            ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}