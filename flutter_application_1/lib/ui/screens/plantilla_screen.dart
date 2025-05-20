import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'template_form_screen.dart';
import 'template_preview_screen.dart';

class PlantillaScreen extends StatelessWidget {
  final String profesorNombre;

  const PlantillaScreen({super.key, this.profesorNombre = "Profesor Braulio"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fondo blanco
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: Text(
          'Bienvenido $profesorNombre',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),

      drawer: _buildSidebar(context),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona la plantilla',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildPlantillaOption(context, 'Generar taller'),
                  _buildPlantillaOption(context, 'Generar plan de estudio'),
                  _buildPlantillaOption(context, 'Generar examen'),
                  _buildPlantillaOption(context, 'Generar quiz'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Drawer(child: Center(child: Text('No hay usuario autenticado')));
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Historial de Plantillas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('plantillas')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No hay plantillas guardadas.'),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data()! as Map<String, dynamic>;
                      final tipo = data['tipoPlantilla'] ?? 'Sin tipo';
                      final tema = data['tema'] ?? 'Sin tema';
                      final fecha = (data['createdAt'] as Timestamp).toDate();

                      return ListTile(
                        title: Text('$tipo - $tema'),
                        subtitle: Text(
                          'Guardado el ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(); // Cierra el drawer
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
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop(); // Cierra drawer
                  Navigator.of(context).pushReplacementNamed('/login');
                  // Ajusta la ruta /login según tu ruta de login
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantillaOption(BuildContext context, String label) {
    final Map<String, String> labelToTemplateType = {
      'Generar taller': 'Talleres',
      'Generar plan de estudio': 'Plan de estudio',
      'Generar examen': 'Exámenes',
      'Generar quiz': 'Quizzes',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TemplateFormScreen(
                    templateType: labelToTemplateType[label]!,
                  ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFAF0A9), // amarillo suave
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.15),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'ComicSansMS',
          ),
        ),
      ),
    );
  }
}
