import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationDetailScreen extends StatelessWidget {
  final String conversationId;
  const ConversationDetailScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('conversation')
      .doc(conversationId)
      .collection('messages')
      .orderBy('timestamp');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de conversación')),
      body: StreamBuilder<QuerySnapshot>(
        stream: messagesRef.snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (ctx2, i) {
              final msg = docs[i].data()! as Map<String, dynamic>;
              final isUser = msg['sender'] == 'user';
              return Align(
                alignment: isUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                      ? Colors.blue.shade100
                      : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(msg['text'] as String),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
