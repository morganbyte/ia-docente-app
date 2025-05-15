import 'package:flutter/material.dart';
import 'dart:convert';

class TemplatePreviewScreen extends StatelessWidget {
  final String jsonResponse;
  final String templateType;

  TemplatePreviewScreen({
    super.key,
    required this.jsonResponse,
    required this.templateType,
  });

  @override
  Widget build(BuildContext context) {
    // Convertir la respuesta en un mapa de datos
    Map<String, dynamic> responseMap = jsonDecode(jsonResponse);

    // Obtener la información que nos interesa con valores predeterminados en caso de null
    String titulo =
        responseMap['tituloQuiz'] ??
        responseMap['nombreTaller'] ??
        responseMap['tituloExamen'] ??
        'Título no disponible';
    List preguntas = responseMap['preguntas'] ?? [];

    // Dependiendo del tipo de plantilla, mostrar los campos correspondientes
    return Scaffold(
      appBar: AppBar(title: const Text("Plantilla Generada")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título: $titulo',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (templateType == 'Quizzes') ...[
              Text('Preguntas:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              ...preguntas.map<Widget>((preguntaData) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pregunta ${preguntaData['numeroPregunta']}: ${preguntaData['pregunta']}',
                        ),
                        const SizedBox(height: 8),
                        Text('Opciones:'),
                        for (var opcion in preguntaData['opciones'] ?? [])
                          Text('- $opcion'),
                        const SizedBox(height: 8),
                        Text(
                          'Respuesta correcta: ${preguntaData['respuestaCorrecta']}',
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
            // Mostrar los campos específicos para Talleres
            if (templateType == 'Talleres') ...[
              Text(
                'Descripción: ${responseMap['descripcionTaller'] ?? 'Descripción no disponible'}',
              ),
              const SizedBox(height: 16),
              Text('Equipo necesario:'),
              const SizedBox(height: 8),
              ...responseMap['equipoNecesario']?.map<Widget>((item) {
                    return ListTile(
                      title: Text(
                        item['nombreMaterial'] ?? 'Material no disponible',
                      ),
                      subtitle: Text(
                        item['descripcionMaterial'] ??
                            'Descripción no disponible',
                      ),
                    );
                  }).toList() ??
                  [],
              const SizedBox(height: 16),
              Text(
                'Objetivo: ${responseMap['objetivoTaller'] ?? 'Objetivo no disponible'}',
              ),
              const SizedBox(height: 16),
              Text('Actividades del taller:'),
              const SizedBox(height: 8),
              ...responseMap['actividadesTaller']?.map<Widget>((actividad) {
                    return ListTile(
                      title: Text(
                        'Actividad ${actividad['numeroActividad']} - ${actividad['tituloActividad']}',
                      ),
                      subtitle: Text(
                        actividad['descripcionActividad'] ??
                            'Descripción no disponible',
                      ),
                    );
                  }).toList() ??
                  [],
            ],
            if (templateType == 'Exámenes') ...[
              // Mostrar el título del examen

              // Mostrar el número de preguntas
              Text(
                'Número de Preguntas: ${responseMap['numeroPregunta'] ?? 0}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Mostrar la duración del examen
              Text(
                'Duración: ${responseMap['duracion'] ?? 0} minutos',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Mostrar la dificultad del examen
              Text(
                'Dificultad: ${responseMap['dificultad'] ?? 'No especificada'}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Mostrar las preguntas y sus opciones
              Text('Preguntas:', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),

              // Mapear y mostrar cada pregunta
              ...responseMap['preguntas']?.map<Widget>((preguntaData) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pregunta ${preguntaData['numeroPregunta']}: ${preguntaData['pregunta']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Opciones:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        for (var opcion in preguntaData['opciones'])
                          Text('- $opcion'),
                        const SizedBox(height: 8),
                        Text(
                          'Respuesta Correcta: ${preguntaData['respuestaCorrecta']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
