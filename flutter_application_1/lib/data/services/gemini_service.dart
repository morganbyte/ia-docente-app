import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/utils/prompt_generator.dart';
import 'package:flutter_application_1/utils/response_cleaner.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  final String _apiKey = 'AIzaSyA1693TDkcaADVhazIbLLsitORij14L43g';
  final String _model = 'gemini-2.0-flash';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getGeminiResponseFromRequest(Map<String, dynamic> request) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado. Por favor, inicie sesión.");
    }

    final prompt = PromptGenerator.generatePrompt(request);

    final requestBody = {
      "contents": [
        {"role": "user", "parts": [{"text": prompt}]}
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 4096,
      }
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al comunicarse con la API de Gemini: ${response.statusCode}');
    }

    final responseData = jsonDecode(response.body);
    String completeText = '';
    
    if (responseData['candidates'] != null && 
        responseData['candidates'].isNotEmpty && 
        responseData['candidates'][0]['content'] != null) {
      final content = responseData['candidates'][0]['content'];
      if (content['parts'] != null && content['parts'].isNotEmpty) {
        completeText = content['parts'][0]['text'];
      }
    }

    if (completeText.isEmpty) {
      throw Exception('No se pudo obtener una respuesta válida del modelo Gemini.');
    }

    completeText = ResponseCleaner.cleanJsonResponse(completeText);

    //final respuestaJson = jsonDecode(completeText);

    final userRef = _firestore.collection('users').doc(user.uid);
    await userRef.collection('plantillas').add({
      'tipoPlantilla': request['tipoPlantilla'],
      'jsonRespuesta': completeText,
      'createdAt': FieldValue.serverTimestamp(),
      'tema': request['tema'],
    });

    return completeText;
  }
}
