import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/pdf_generator_service.dart';
import 'dart:convert';

class TemplatePreviewScreen extends StatelessWidget {
  final String jsonResponse;
  final String templateType;

  const TemplatePreviewScreen({
    super.key,
    required this.jsonResponse,
    required this.templateType,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> responseMap = jsonDecode(jsonResponse);

    String titulo =
        responseMap['tituloQuiz'] ??
        responseMap['nombreTaller'] ??
        responseMap['tituloExamen'] ??
        'Título no disponible';

    List preguntas = responseMap['preguntas'] ?? [];

    TextSpan buildPreguntaSpan(Map preguntaData) {
      final opciones = preguntaData['opciones'] ?? [];

      return TextSpan(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: 'Pregunta ${preguntaData['numeroPregunta']}: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '${preguntaData['pregunta']}\n\n'),
          const TextSpan(
            text: 'Opciones:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...opciones
              .map<TextSpan>((opcion) => TextSpan(text: '- $opcion\n'))
              .toList(),
          TextSpan(
            text: '\nRespuesta Correcta: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '${preguntaData['respuestaCorrecta']}\n\n'),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantilla Generada'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectableText.rich(
              TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(
                    text: 'Título: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    text: '$titulo\n\n',
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (templateType == 'Quizzes' ||
                      templateType == 'Exámenes') ...[
                    const TextSpan(
                      text: 'Preguntas\n\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    ...preguntas
                        .map<TextSpan>((p) => buildPreguntaSpan(p))
                        .toList(),
                  ],
                  if (templateType == 'Talleres') ...[
                    const TextSpan(
                      text: 'Descripción:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${responseMap['descripcionTaller'] ?? 'No disponible'}\n\n',
                    ),
                    const TextSpan(
                      text: 'Equipo necesario:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: (responseMap['equipoNecesario'] ?? [])
                          .map(
                            (e) =>
                                '- ${e['material'] ?? 'Material'}: ${e['descripcion'] ?? ''}',
                          )
                          .join('\n'),
                    ),
                    const TextSpan(text: '\n\n'),
                    const TextSpan(
                      text: 'Objetivo:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${responseMap['objetivoTaller'] ?? 'No disponible'}\n\n',
                    ),
                    const TextSpan(
                      text: 'Actividades del taller:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: (responseMap['actividadesTaller'] ?? [])
                          .map(
                            (a) =>
                                '- Actividad ${a['numeroActividad'] ?? ''}: ${a['tituloActividad'] ?? ''} - ${a['descripcionActividad'] ?? ''}',
                          )
                          .join('\n'),
                    ),
                  ],
                  if (templateType == 'Exámenes') ...[
                    const TextSpan(
                      text: '\nDuración:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: '${responseMap['duracion'] ?? 0} minutos\n\n',
                    ),
                    const TextSpan(
                      text: 'Dificultad:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${responseMap['dificultad'] ?? 'No especificada'}\n',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar a PDF'),
              onPressed: () {
                final Map<String, dynamic> data = jsonDecode(jsonResponse);
                generateAndPrintPdf(data, templateType);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
