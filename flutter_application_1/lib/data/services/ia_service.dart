import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// Mantenemos el mismo nombre de clase para facilitar la migración
class DeepSeekService {
  // URL base de la API de Gemini
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  final String _apiKey = 'AIzaSyA1693TDkcaADVhazIbLLsitORij14L43g';
  final String _model = 'gemini-2.0-flash';
  String? _conversationId;

  /// Método para enviar el historial del chat y obtener respuesta de Gemini
  /// (mantenemos la misma firma de método para facilitar la migración)
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

    // Convertir mensajes a formato de API de Gemini
    final requestMessages = messages.map((msg) {
      return {
        "role": msg['tipo'] == 'user' ? 'user' : 'model',
        "parts": [{"text": msg['mensaje'] ?? ''}]
      };
    }).toList();

    final requestData = {
      "contents": requestMessages,
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 1024,
      }
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en Gemini: ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    String reply = '';
    
    // Extraer la respuesta del modelo Gemini
    if (responseData['candidates'] != null && 
        responseData['candidates'].isNotEmpty && 
        responseData['candidates'][0]['content'] != null) {
      final content = responseData['candidates'][0]['content'];
      if (content['parts'] != null && content['parts'].isNotEmpty) {
        reply = content['parts'][0]['text'];
      }
    }

    if (reply.isEmpty) {
      throw Exception('No se pudo obtener una respuesta del modelo Gemini.');
    }

    // Guardar respuesta en Firestore
    await messagesRef.add({
      'sender': 'bot',
      'text': reply,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return reply;
  }

  /// Método alternativo para plantillas (mantenemos el mismo nombre para facilitar la migración)
  Future<String> getDeepSeekResponseFromRequest(Map<String, dynamic> request) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final prompt = _generatePrompt(request);
    
    // Corregido para usar la API de Gemini correctamente
    final requestBody = {
      "contents": [
        {"role": "user", "parts": [{"text": prompt}]}
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 2048,
      }
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en Gemini: ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    String completeText = '';
    
    // Extraer la respuesta del modelo Gemini
    if (responseData['candidates'] != null && 
        responseData['candidates'].isNotEmpty && 
        responseData['candidates'][0]['content'] != null) {
      final content = responseData['candidates'][0]['content'];
      if (content['parts'] != null && content['parts'].isNotEmpty) {
        completeText = content['parts'][0]['text'];
      }
    }

    if (completeText.isEmpty) {
      throw Exception('No se pudo obtener una respuesta del modelo Gemini.');
    }
    
    // Limpiar la respuesta de bloques de código markdown y otros elementos no deseados
    completeText = _limpiarRespuestaJSON(completeText);

    // Guardar conversación si es nueva
    if (_conversationId == null) {
      final convDoc = await userRef.collection('plantillas').add({
        'tipo': request['tipoPlantilla'],
        'prompt': prompt,
        'respuesta': completeText,
        'createdAt': FieldValue.serverTimestamp(),
        'preview': prompt,
      });
      _conversationId = convDoc.id;
    }

    // Guardar en subcolección de mensajes
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
      'text': completeText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return completeText;
  }

  // Función para generar el prompt adecuado según la plantilla
  String _generatePrompt(Map<String, dynamic> request) {
    switch (request['tipoPlantilla']) {
      case 'Exámenes':
        return '''
Genera un examen sobre el tema "${request['tema']}" de ${request['numeroPreguntas']} preguntas con una duración de ${request['duracion']} y que sea de dificultad ${request['dificultad']}.

IMPORTANTE: Responde SOLAMENTE con un cuerpo JSON válido sin ningún texto antes o después. El JSON debe comenzar con { y terminar con }. NO ENCIERRES EL JSON EN NINGÚN TIPO DE BLOQUE DE CÓDIGO NI COMILLAS TRIPLES.

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
Genera una plantilla para un taller sobre ${request['tema']} con una duración de ${request['duracion']} y con ${request['numeroActividades']} actividades sencillas relacionadas al tema. 

IMPORTANTE: Responde SOLAMENTE con un cuerpo JSON válido sin ningún texto antes o después. El JSON debe comenzar con { y terminar con }. NO ENCIERRES EL JSON EN NINGÚN TIPO DE BLOQUE DE CÓDIGO NI COMILLAS TRIPLES.

El JSON debe tener los siguientes campos:
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
Genera un plan de estudio detallado sobre el tema "${request['tema']}". 

IMPORTANTE: Responde SOLAMENTE con un cuerpo JSON válido sin ningún texto antes o después. El JSON debe comenzar con { y terminar con }. NO ENCIERRES EL JSON EN NINGÚN TIPO DE BLOQUE DE CÓDIGO NI COMILLAS TRIPLES.

El JSON debe incluir los siguientes campos:
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
Genera un quiz sobre el tema "${request['tema']}", de ${request['numeroPreguntas']} preguntas relacionadas. Debe tener una duración de ${request['duracion']}. 

IMPORTANTE: Responde SOLAMENTE con un cuerpo JSON válido sin ningún texto antes o después. El JSON debe comenzar con { y terminar con }. NO ENCIERRES EL JSON EN NINGÚN TIPO DE BLOQUE DE CÓDIGO NI COMILLAS TRIPLES.

El JSON debe incluir los siguientes campos:
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

  // Función para limpiar la respuesta JSON de delimitadores markdown y texto adicional
  String _limpiarRespuestaJSON(String texto) {
    // Eliminar los delimitadores del bloque de código markdown si están presentes
    if (texto.startsWith('```json')) {
      texto = texto.substring(7); // Eliminar '```json'
    } else if (texto.startsWith('```')) {
      texto = texto.substring(3); // Eliminar '```'
    }
    
    // Eliminar el delimitador final si existe
    if (texto.endsWith('```')) {
      texto = texto.substring(0, texto.length - 3); // Eliminar '```'
    }
    
    // Eliminar cualquier espacio en blanco al principio o al final
    texto = texto.trim();
    
    // Buscar el primer '{' y el último '}'
    int startIndex = texto.indexOf('{');
    int endIndex = texto.lastIndexOf('}') + 1;
    
    if (startIndex != -1 && endIndex > startIndex) {
      // Extraer solo la parte JSON
      texto = texto.substring(startIndex, endIndex);
    }
    
    print("RESPUESTA JSON LIMPIA:");
    print(texto);
    
    return texto;
  }

  void resetConversation() {
    _conversationId = null;
  }
}