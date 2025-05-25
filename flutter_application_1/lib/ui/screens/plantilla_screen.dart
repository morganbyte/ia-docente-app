import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; 

import 'package:flutter_application_1/config/app_colors.dart'; 
import 'package:flutter_application_1/ui/widgets/sidebar_header.dart'; 
import 'package:flutter_application_1/ui/widgets/sidebar_history_list.dart'; 
import 'package:flutter_application_1/ui/widgets/sidebar_logout_button.dart'; 
import 'package:flutter_application_1/ui/widgets/template_app_bar.dart';
import 'package:flutter_application_1/ui/widgets/template_card.dart';

import 'template_form_screen.dart'; 


class PlantillaScreen extends StatefulWidget {
  const PlantillaScreen({super.key});

  @override
  State<PlantillaScreen> createState() => _PlantillaScreenState();
}

class _PlantillaScreenState extends State<PlantillaScreen> {
  String _userName = "Cargando...";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _getDisplayName();
    setState(() {
      _userName = name;
    });
  }

  Future<String> _getDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Invitado";

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!;
    }

    return "Usuario";
  }

  void _showDeleteConfirmation(BuildContext context, String documentId, String tema) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Eliminar plantilla',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar la plantilla "$tema"?\n\nEsta acción no se puede deshacer.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteTemplate(documentId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent3,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTemplate(String documentId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('plantillas')
            .doc(documentId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Plantilla eliminada correctamente',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.accent1,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Error al eliminar la plantilla',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.accent3,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PlantillaAppBar(userName: _userName), 
      drawer: _buildSidebar(context, _userName), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Genera el enlace a tus estudiantes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  const urlToCopy = 'https://ia-docente-templates.web.app/'; 
                  await Clipboard.setData(const ClipboardData(text: urlToCopy));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Enlace copiado al portapapeles!'),
                        backgroundColor: AppColors.accent1,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        margin: EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Copiar enlace de plantillas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    PlantillaCard( 
                      label: 'Talleres',
                      icon: Icons.assignment_outlined,
                      description: 'Generar material para actividades prácticas',
                      gradientColors: const [AppColors.primary, AppColors.secondary],
                      templateType: 'Talleres',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TemplateFormScreen(
                              templateType: 'Talleres',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    PlantillaCard(
                      label: 'Temario',
                      icon: Icons.calendar_today_outlined,
                      description: 'Crear estructuras curriculares organizadas',
                      gradientColors: const [AppColors.accent1, AppColors.accent2],
                      templateType: 'Temario',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TemplateFormScreen(
                              templateType: 'Temario',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    PlantillaCard( 
                      label: 'Exámenes',
                      icon: Icons.quiz_outlined,
                      description: 'Elaborar evaluaciones formales',
                      gradientColors: const [AppColors.accent3, AppColors.secondary],
                      templateType: 'Exámenes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TemplateFormScreen(
                              templateType: 'Exámenes',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    PlantillaCard( 
                      label: 'Quizzes',
                      icon: Icons.help_outline,
                      description: 'Diseñar evaluaciones cortas y ágiles',
                      gradientColors: const [AppColors.accent4, AppColors.accent2],
                      templateType: 'Quizzes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TemplateFormScreen(
                              templateType: 'Quizzes',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, String userName) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            SidebarHeader(userName: userName), 
            const SizedBox(height: 24),
            Expanded(
              child: SidebarHistoryList( 
                currentUser: user,
                onDelete: _showDeleteConfirmation, 
              ),
            ),
            SidebarLogoutButton( 
              onLogout: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pop(); 
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}