import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/screens/detalle_plantilla_screen.dart';
import 'conversation_detail_screen.dart';

class HistorialScreen extends StatelessWidget {
  final String tipo; // 'chats' o 'plantillas'

  const HistorialScreen({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final collectionName = tipo == 'plantillas' ? 'plantillas' : 'conversation';

    final threadsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(collectionName)
        .orderBy('createdAt', descending: true);

    final titulo = tipo == 'plantillas'
        ? 'Historial de plantillas'
        : 'Historial de conversaciones';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB3E5FC), Color(0xFFE1BEE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            titulo,
            style: const TextStyle(color: Colors.black87),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: threadsRef.snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            }

            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  tipo == 'plantillas'
                      ? 'No hay plantillas guardadas.'
                      : 'No hay conversaciones guardadas.',
                  style: const TextStyle(color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (ctx, i) {
                final thread = docs[i];
                final ts = (thread['createdAt'] as Timestamp?)?.toDate();
                final dateStr = ts != null
                    ? '${ts.day}/${ts.month}/${ts.year} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}'
                    : '';

                final data = thread.data() as Map<String, dynamic>;
final preview = data['preview'] ?? 'Conversación sin vista previa';


                return Card(
                  key: ValueKey(thread.id),
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  elevation: 6,
                  shadowColor: Colors.purple.withOpacity(0.2),
                  child: ListTile(
                    title: Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    subtitle: Text(
                      dateStr,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.deepPurple),
                    onTap: () {
  if (tipo == 'chats') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationDetailScreen(
          conversationId: thread.id,
        ),
      ),
    );
  } else {
  final data = thread.data();
  if (data is Map<String, dynamic>) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallePlantillaScreen(
          plantillaData: data,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: datos de plantilla inválidos')),
    );
  }
}

}
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
