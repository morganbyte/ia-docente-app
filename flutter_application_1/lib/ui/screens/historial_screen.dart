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
        .collection('conversation')
        .orderBy('createdAt', descending: true);

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
          title: const Text(
            'Historial de conversaciones',
            style: TextStyle(color: Colors.black87),
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
              return const Center(
                child: Text(
                  'No hay conversaciones guardadas.',
                  style: TextStyle(color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (ctx, i) {
                final thread = docs[i];
                final convId = thread.id;
                final ts = (thread['createdAt'] as Timestamp?)?.toDate();
                final dateStr = ts != null
                    ? '${ts.day}/${ts.month}/${ts.year} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}'
                    : '';

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

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        key: ValueKey(convId),
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
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
