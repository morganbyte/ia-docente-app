import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_colors.dart';

class PlantillaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  const PlantillaAppBar({
    super.key,
    required this.userName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textDark),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido Profesor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
          Text(
            userName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith( 
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 18, 
                  letterSpacing: -0.3,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      centerTitle: false,
    );
  }
}