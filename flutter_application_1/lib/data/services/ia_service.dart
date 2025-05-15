import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class DeepSeekService {
  final String _baseUrl = 'http://10.0.2.2:11434/api/chat'; // Dirección del servidor local
  String? _conversationId;

  /// Método para enviar el historial del chat y obtener respuesta de la IA
  Future<String> getChatResponse(List<Map<String, String>> messages) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Crear conversación si no existe
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

    // Almacenar en Firestore el nuevo mensaje del usuario
    final ultimoMensaje = messages.last;
    if (ultimoMensaje['tipo'] == 'user') {
      await messagesRef.add({
        'sender': 'user',
        'text': ultimoMensaje['mensaje'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Convertir mensajes a formato de API de chat (tipo OpenAI)
    final requestMessages = messages.map((msg) {
      return {
        "role": msg['tipo'] == 'user' ? 'user' : 'assistant',
        "content": msg['mensaje'] ?? '',
      };
    }).toList();

    final requestData = {
      "model": "mistral",
      "messages": requestMessages,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en DeepSeek: ${response.body}');
    }

    final responseLines = const LineSplitter().convert(utf8.decode(response.bodyBytes));

    StringBuffer replyBuffer = StringBuffer();
    for (var line in responseLines) {
      if (line.trim().isEmpty) continue;
      final Map<String, dynamic> json = jsonDecode(line);
      if (json.containsKey('message')) {
        final content = json['message']['content'];
        if (content != null) {
          replyBuffer.write(content);
        }
      }
    }

    final reply = replyBuffer.toString().trim();

    if (reply.isEmpty) {
      throw Exception('No se pudo obtener una respuesta del modelo.');
    }

    // Guardar respuesta en Firestore
    await messagesRef.add({
      'sender': 'bot',
      'text': reply,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return reply;
  }

  /// Método alternativo para plantillas (puedes mejorarlo similar al anterior si deseas)
  Future<String> getDeepSeekResponse(
    String prompt,
    String tipoPlantilla,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

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

    final requestData = {
      "tipoPlantilla": tipoPlantilla,
      "model": "mistral",
      "tema": prompt,
      "numeroPreguntas": 5,
      "dificultad": "media",
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer sk-b959c7a0e22d49cb8dab076f6c344805',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en DeepSeek: ${response.body}');
    }

    final responseLines = const LineSplitter().convert(utf8.decode(response.bodyBytes));

    StringBuffer replyBuffer = StringBuffer();
    for (var line in responseLines) {
      if (line.trim().isEmpty) continue;
      final Map<String, dynamic> json = jsonDecode(line);
      if (json.containsKey('message')) {
        final content = json['message']['content'];
        if (content != null) {
          replyBuffer.write(content);
        }
      }
    }

    final reply = replyBuffer.toString().trim();

    if (reply.isEmpty) {
      throw Exception('No se pudo obtener una respuesta del modelo.');
    }

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

