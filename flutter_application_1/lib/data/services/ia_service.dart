import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = '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';
  // Guardamos la conversación activa para seguir el hilo
  String? _conversationId;

  Future<String> getOpenAIResponse(String prompt) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

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

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        //'HTTP-Referer': 'https://tu-app.com',
        //'X-Title': 'FlutterChatBotDemo',
      },
      body: jsonEncode({
        "model": "openai/gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en la API: ${response.body}');
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
