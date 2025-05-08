import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class DeepSeekService {
  final String _baseUrl =
      'http://10.0.2.2:11434/api/chat'; // Dirección de tu servidor local

  String? _conversationId;

  Future<String> getDeepSeekResponse(
    String prompt,
    String tipoPlantilla,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    // Verifica si ya existe una conversación, si no, crea una nueva
    if (_conversationId == null) {
      final convDoc = await userRef.collection('conversation').add({
        'createdAt': FieldValue.serverTimestamp(),
      });
      _conversationId = convDoc.id;
    }

    // Referencia para guardar los mensajes
    final messagesRef = userRef
        .collection('conversation')
        .doc(_conversationId)
        .collection('messages');

    // Guarda el mensaje del usuario en Firestore
    await messagesRef.add({
      'sender': 'user',
      'text': prompt,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Construye los datos que se enviarán a la IA
    final requestData = {
      "tipoPlantilla":
          tipoPlantilla, // Tipo de plantilla (Ej: temario, examen, etc.)
      "model": "mistral", // El modelo que estás utilizando
      "tema": prompt, // Tema para generar la plantilla
      "numeroPreguntas": 5, // Cantidad de preguntas en el caso de un examen
      "dificultad": "media", // Dificultad de las preguntas (opcional)
    };

    // Realiza la solicitud HTTP al servidor de DeepSeek (localmente)
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer sk-b959c7a0e22d49cb8dab076f6c344805'},
          body: jsonEncode(requestData),
        );

    if (response.statusCode != 200) {
      print('Error en la respuesta de DeepSeek: ${response.statusCode}');
      throw Exception('Error en DeepSeek: ${response.body}');
    } else {
      print("Respuesta exitosa");
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data == null ||
        !data.containsKey('choices') ||
        data['choices'].isEmpty) {
      throw Exception('Respuesta inválida de DeepSeek');
    }
    print('Datos recibidos: $data');

    // Ajusta aquí el acceso a la respuesta según la estructura del JSON que recibas
    final String reply = data['choices'][0]['message']['content'];

    // Guarda la respuesta de la IA en Firestore
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
