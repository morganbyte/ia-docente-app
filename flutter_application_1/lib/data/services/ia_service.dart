import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class DeepSeekService {
  final String _baseUrl = 'http://10.0.2.2:11434/api/chat';

  String? _conversationId;

  Future<String> getDeepSeekResponse(String prompt, String tipoPlantilla) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    if (_conversationId == null) {
      final convDoc = await userRef.collection('conversation').add({
        'createdAt': FieldValue.serverTimestamp(),
      });
      _conversationId = convDoc.id;
    }

    final messagesRef = userRef
        .collection('conversation')
        .doc(_conversationId)
        .collection('messages');

    await messagesRef.add({
      'sender': 'user',
      'text': prompt,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final requestData = {
      "tipoPlantilla": tipoPlantilla,
      "tema": prompt,
      "numeroPreguntas": 5,
      "dificultad": "media",
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en DeepSeek: ${response.body}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final String reply = data['choices'][0]['message']['content'];

    await messagesRef.add({
      'sender': 'bot',
      'text': reply,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return reply;
  }

  void resetConversation() {
    _conversationId = null;
  }
}
