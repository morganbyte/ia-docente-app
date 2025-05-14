import 'package:flutter/material.dart';
import 'dart:convert';

class TemplatePreviewScreen extends StatelessWidget {
  final String jsonResponse;

  TemplatePreviewScreen({super.key, required this.jsonResponse});

  @override
  Widget build(BuildContext context) {
    // Convertir la respuesta en un mapa de datos
    Map<String, dynamic> responseMap = jsonDecode(jsonResponse);

    // Obtener la información que nos interesa
    String tituloQuiz = responseMap['tituloQuiz'] ?? 'Titulo no disponible';
    int numeroPreguntas = responseMap['numeroPreguntas'] ?? 0;
    List preguntas = responseMap['preguntas'] ?? [];
    int duracion = responseMap['duracion'] ?? 0;

    // Mostrar el contenido
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plantilla Generada"),
      ),
      body: SingleChildScrollView(  // Usamos SingleChildScrollView para evitar desbordamientos
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título: $tituloQuiz',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Número de preguntas: $numeroPreguntas'),
            const SizedBox(height: 16),
            Text('Duración: $duracion minutos'),
            const SizedBox(height: 16),
            Text('Preguntas:', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            // Mostrar cada pregunta con sus opciones
            ...preguntas.map<Widget>((preguntaData) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pregunta ${preguntaData['numeroPregunta']}: ${preguntaData['pregunta']}'),
                      const SizedBox(height: 8),
                      Text('Opciones:'),
                      for (var opcion in preguntaData['opciones'])
                        Text('- $opcion'),
                      const SizedBox(height: 8),
                      Text('Respuesta correcta: ${preguntaData['respuestaCorrecta']}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
