import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class DeepSeekService {
  final String _baseUrl = 'http://10.0.2.2:11434/api/chat';
  String? _conversationId;

  Future<String> getDeepSeekResponseFromRequest(
    Map<String, dynamic> request,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    if (_conversationId == null) {
      final convDoc = await userRef.collection('conversation').add({
        'createdAt': FieldValue.serverTimestamp(),
      });
      _conversationId = convDoc.id;
    }

    // Generamos el prompt dependiendo del tipo de plantilla
    final prompt = _generatePrompt(request);

    final messagesRef = userRef
        .collection('conversation')
        .doc(_conversationId)
        .collection('messages');

    await messagesRef.add({
      'sender': 'user',
      'text': prompt,
      'timestamp': FieldValue.serverTimestamp(),
    });

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

    final completeJsonText = fullContent.toString();
    print("RESPUESTA COMPLETA:");
    print(completeJsonText);

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
Genera un examen sobre el tema "${request['tema']}" de ${request['numeroPreguntas']} preguntas con una duración de ${request['duracion']} y que sea de dificultad ${request['dificultad']}. Devuelve un JSON estructurado que debe incluir los siguientes campos:

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
Genera una plantilla para un taller sobre ${request['tema']} con una duración de ${request['duracion']} y con ${request['numeroActividades']} actividades sencillas relacionadas al tema. Devuelve un JSON estructurado que debe tener los siguientes campos:

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
Genera un plan de estudio detallado sobre el tema "${request['tema']}". Devuelve un JSON estructurado que debe incluir los siguientes campos:

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
Genera un quiz sobre el tema "${request['tema']}", de ${request['numeroPreguntas']} preguntas relacionadas. Debe tener una duración de ${request['duracion']}. Devuelve un JSON estructurado que debe incluir los siguientes campos:

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
