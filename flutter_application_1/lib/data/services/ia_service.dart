import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey =
      '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';

  Future<String> getOpenAIResponse(String prompt) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final User? user = FirebaseAuth.instance.currentUser;

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://tu-app.com',
        'X-Title': 'FlutterChatBotDemo',
      },
      body: jsonEncode({
        "model": "openai/gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final String reply = data['choices'][0]['message']['content'];

      // Guardar historial en Firestore
      if (user != null) {
        final chatRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('historial');
        if (user != null) {
          print('Usuario autenticado: ${user.uid}');
        } else {
          print('No hay usuario autenticado');
        }
        try {
          await chatRef.add({
            'pregunta': prompt,
            'respuesta': reply,
            'timestamp': FieldValue.serverTimestamp(),
          });
          print('Historial guardado con éxito');
        } catch (e) {
          print('Error al guardar historial: $e');
        }
      }

      return reply;
    } else {
      throw Exception('Error en la API: ${response.body}');
    }
  }
}
