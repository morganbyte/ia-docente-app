import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'conversation_detail_screen.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final threadsRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de conversaciones')),
      body: StreamBuilder<QuerySnapshot>(
        stream: threadsRef.snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay conversaciones guardadas.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final thread = docs[i];
              final convId = thread.id;
              final ts = (thread['createdAt'] as Timestamp?)?.toDate();
              final dateStr = ts != null
                ? '${ts.day}/${ts.month}/${ts.year} ${ts.hour}:${ts.minute.toString().padLeft(2,'0')}'
                : '';

              // Mostramos un preview: la PRIMERA pregunta del hilo
              return FutureBuilder<QuerySnapshot>(
                future: thread.reference
                  .collection('messages')
                  .orderBy('timestamp')
                  .limit(1)
                  .get(),
                builder: (ctx2, msgSnap) {
                  String preview = '—';
                  if (msgSnap.hasData && msgSnap.data!.docs.isNotEmpty) {
                    preview = msgSnap.data!.docs.first['text'] as String;
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(dateStr),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConversationDetailScreen(
                              conversationId: convId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 0) Navigator.pushReplacementNamed(context, '/');
          if (idx == 2) Navigator.pushReplacementNamed(context, '/plantillas');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),    label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.view_module), label: 'Plantillas'),
        ],
      ),
    );
  }
}
