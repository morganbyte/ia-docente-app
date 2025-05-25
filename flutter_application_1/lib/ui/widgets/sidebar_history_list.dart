import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/config/app_colors.dart';
import 'package:flutter_application_1/ui/screens/template_preview_screen.dart'; 

class SidebarHistoryList extends StatelessWidget {
  final User? currentUser;
  final void Function(BuildContext context, String documentId, String tema) onDelete;

  const SidebarHistoryList({
    super.key,
    required this.currentUser,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Center(
        child: Text(
          'No hay usuario autenticado',
          style: TextStyle(fontSize: 16, color: AppColors.textMedium),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.accent1,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Historial de Plantillas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('plantillas')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 48,
                        color: AppColors.textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No hay plantillas guardadas',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: docs.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade100,
                        indent: 52,
                      ),
                  itemBuilder: (context, index) {
                    final data = docs[index].data()! as Map<String, dynamic>;
                    final documentId = docs[index].id;
                    final tipo = data['tipoPlantilla'] ?? 'Sin tipo';
                    final tema = data['tema'] ?? 'Sin tema';

                    Color accentColor;
                    switch (tipo) {
                      case 'Talleres':
                        accentColor = AppColors.primary;
                        break;
                      case 'Temario':
                        accentColor = AppColors.accent1;
                        break;
                      case 'Exámenes':
                        accentColor = AppColors.accent3;
                        break;
                      case 'Quizzes':
                        accentColor = AppColors.accent4;
                        break;
                      default:
                        accentColor = AppColors.primary;
                    }

                    return InkWell(
                      onTap: () {
                        // Cierra drawer automáticamente al navegar
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => TemplatePreviewScreen(
                                  jsonResponse: data['jsonRespuesta'] ?? '{}',
                                  templateType: tipo,
                                ),
                          ),
                        );
                      },
                      borderRadius:
                          index == 0
                              ? const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              )
                              : index == docs.length - 1
                              ? const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              )
                              : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Indicador de color
                            Container(
                              width: 4,
                              height: 36,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Contenido principal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tema,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tipo,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Botón de eliminar
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onDelete(context,documentId, tema),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
