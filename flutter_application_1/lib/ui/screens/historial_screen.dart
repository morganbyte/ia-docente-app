import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/screens/conversation_detail_screen.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    final historialRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('historial')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de conversaciones')),
      body: StreamBuilder<QuerySnapshot>(
        stream: historialRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay historial disponible.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final pregunta = data['pregunta'] ?? 'Sin pregunta';
              final respuesta = data['respuesta'] ?? 'Sin respuesta';
              final timestamp = data['timestamp'] as Timestamp?;
              
              // Convertir Timestamp a DateTime
              DateTime? date = timestamp?.toDate();

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    pregunta,
                    style: Theme.of(context).textTheme.headlineMedium, // Actualizado a headlineMedium
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConversationDetailScreen(
                          conversationId: docs[index].id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Asumiendo que estamos en la pantalla de historial
        onTap: (index) {
          if (index == 0) {
            // Redirigir a la pantalla de inicio
            Navigator.pushReplacementNamed(context, '/inicio');
          } else if (index == 2) {
            // Redirigir a la pantalla de plantillas
            Navigator.pushReplacementNamed(context, '/plantillas');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.view_module), label: 'Plantillas'),
        ],
      ),
    );
  }
}

class ConversacionDetalleScreen extends StatelessWidget {
  final String pregunta;
  final String respuesta;
  final DateTime? timestamp;

  const ConversacionDetalleScreen({
    super.key,
    required this.pregunta,
    required this.respuesta,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la conversación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregunta:',
              style: Theme.of(context).textTheme.titleMedium, // Actualizado a titleMedium
            ),
            const SizedBox(height: 8.0),
            Text(pregunta, style: Theme.of(context).textTheme.bodyMedium), // Actualizado a bodyMedium
            const SizedBox(height: 16.0),
            Text(
              'Respuesta:',
              style: Theme.of(context).textTheme.titleMedium, // Actualizado a titleMedium
            ),
            const SizedBox(height: 8.0),
            Text(respuesta, style: Theme.of(context).textTheme.bodyMedium), // Actualizado a bodyMedium
            const SizedBox(height: 16.0),
            if (timestamp != null)
              Text('Fecha: ${timestamp!}'),
          ],
        ),
      ),
    );
  }
}
