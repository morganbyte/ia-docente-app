import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_colors.dart'; 

class SidebarLogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const SidebarLogoutButton({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, size: 18, color: AppColors.textMedium),
          label: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }
}