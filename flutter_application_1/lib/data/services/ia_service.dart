import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class DeepSeekService {
  final String _baseUrl = 'http://10.0.2.2:11434/api/chat';
  String? _conversationId;

  Future<String> getChatResponse(List<Map<String, String>> messages) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final ultimoMensaje = messages.last;

    // Crear conversación si no existe y guardar el preview
    if (_conversationId == null) {
      final convDoc = await userRef.collection('conversation').add({
        'createdAt': FieldValue.serverTimestamp(),
        'preview': ultimoMensaje['mensaje'] ?? '', // NUEVO: guardamos el preview
      });
      _conversationId = convDoc.id;
    }

    final messagesRef = userRef
        .collection('conversation')
        .doc(_conversationId)
        .collection('messages');

    if (ultimoMensaje['tipo'] == 'user') {
      await messagesRef.add({
        'sender': 'user',
        'text': ultimoMensaje['mensaje'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

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
    if (reply.isEmpty) throw Exception('No se pudo obtener una respuesta del modelo.');

    await messagesRef.add({
      'sender': 'bot',
      'text': reply,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return reply;
  }

 Future<String> getDeepSeekResponseFromRequest(
  Map<String, dynamic> request,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("Usuario no autenticado");

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final prompt = _generatePrompt(request); // generar prompt ANTES de usarlo

  final requestBody = jsonEncode({
    "model": request["model"],
    "messages": [
      {"role": "user", "content": prompt},
    ],
    "stream": true,
  });

  final requestHttp = http.Request('POST', Uri.parse(_baseUrl));
  requestHttp.headers['Content-Type'] = 'application/json';
  requestHttp.body = requestBody;

  final responseStream = await requestHttp.send();
  final fullContent = StringBuffer();

  await responseStream.stream.transform(utf8.decoder).listen((chunk) {
    try {
      final lines = chunk.trim().split("\n");
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final json = jsonDecode(line);
        final content = json['message']?['content'];
        if (content != null) fullContent.write(content);
      }
    } catch (e) {
      print("Error leyendo chunk: $e");
    }
  }).asFuture();

  final completeJsonText = fullContent.toString(); // ✅ ahora sí se puede usar

  if (_conversationId == null) {
    final convDoc = await userRef.collection('plantillas').add({
      'tipo': request['tipoPlantilla'],
      'prompt': prompt,
      'respuesta': completeJsonText, // ✅ ya está definido
      'createdAt': FieldValue.serverTimestamp(),
      'preview': prompt,
    });
    _conversationId = convDoc.id;
  }

  final messagesRef = userRef
      .collection('plantillas')
      .doc(_conversationId)
      .collection('messages');

  await messagesRef.add({
    'sender': 'user',
    'text': prompt,
    'timestamp': FieldValue.serverTimestamp(),
  });

  await messagesRef.add({
    'sender': 'bot',
    'text': completeJsonText,
    'timestamp': FieldValue.serverTimestamp(),
  });

  return completeJsonText;
}


  // Función para generar el prompt adecuado según la plantilla
  String _generatePrompt(Map<String, dynamic> request) {
    switch (request['tipoPlantilla']) {
      case 'Exámenes':
        return '''
Genera un examen sobre el tema "${request['tema']}" de ${request['numeroPreguntas']} preguntas con una duración de ${request['duracion']} y que sea de dificultad ${request['dificultad']}. Responde únicamente el cuerpo de un JSON estructurado que debe incluir los siguientes campos:

1. tituloExamen: El título del examen.
2. numeroPreguntas: El número total de preguntas en el examen.
3. preguntas: Una lista de preguntas con las siguientes características:
   - numeroPregunta: Un número que identifica la pregunta.
   - pregunta: El texto de la pregunta.
   - opciones: Las opciones de respuesta (si es de opción múltiple).
   - respuestaCorrecta: La respuesta correcta.
4. duracion: Duración del examen en minutos.
5. dificultad: Dificultad del examen (fácil, media, difícil).
''';

      case 'Talleres':
        return '''
Genera una plantilla para un taller sobre ${request['tema']} con una duración de ${request['duracion']} y con ${request['numeroActividades']} actividades sencillas relacionadas al tema. Responde únicamente el cuerpo de un JSON estructurado que debe tener los siguientes campos:

1. nombreTaller: El nombre del taller.
2. descripcionTaller: Una breve descripción del taller.
3. equipoNecesario: Lista de materiales necesarios, incluyendo una descripción de cada uno.
4. objetivoTaller: El objetivo del taller.
5. actividadesTaller: Una lista con la cantidad de actividades dada con los siguientes campos:
   - numeroActividad: Un número que identifica la actividad.
   - tituloActividad: El título de la actividad.
   - descripcionActividad: Descripción de la actividad.
''';

      case 'Plan de Estudio':
        return '''
Genera un plan de estudio detallado sobre el tema "${request['tema']}". Responde únicamente el cuerpo de un JSON estructurado que debe incluir los siguientes campos:

1. tituloCurso: El nombre del curso sobre ${request['tema']}.
2. numeroLecciones: El número total de lecciones.
3. lecciones: Una lista de lecciones con los siguientes campos:
   - numeroLeccion: Un número que identifica la lección.
   - tituloLeccion: El título de la lección.
   - objetivoLeccion: El objetivo de la lección.
   - duracionLeccion: La duración de la lección en minutos.
''';

      case 'Quizzes':
        return '''
Genera un quiz sobre el tema "${request['tema']}", de ${request['numeroPreguntas']} preguntas relacionadas. Debe tener una duración de ${request['duracion']}. Responde únicamente el cuerpo de un JSON estructurado que debe incluir los siguientes campos:

1. tituloQuiz: El nombre del quiz.
2. numeroPreguntas: El número de preguntas.
3. preguntas: Una lista con la cantidad de preguntas dada con los siguientes campos:
   - numeroPregunta: Un número que identifica la pregunta.
   - pregunta: El texto de la pregunta.
   - opciones: Las opciones de respuesta.
   - respuestaCorrecta: La respuesta correcta.
4. duracion: Duración del quiz en minutos.
''';

      default:
        return '';
    }
  }

  void resetConversation() {
    _conversationId = null;
  }
}
