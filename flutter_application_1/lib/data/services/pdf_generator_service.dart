import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

Future<Uint8List> generatePdfBytes(
  Map<String, dynamic> data,
  String templateType,
) async {
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final ttfFont = pw.Font.ttf(fontData);
  final pdf = pw.Document(theme: pw.ThemeData.withFont(base: ttfFont));

  switch (templateType) {
    case 'Quizzes':
      await _generateQuizPdf(pdf, data);
      break;
    case 'Talleres':
      await _generateTallerPdf(pdf, data);
      break;
    case 'Plan de Estudio':
      await _generatePlanEstudioPdf(pdf, data);
      break;
    case 'Exámenes':
      await _generateExamenPdf(pdf, data);
      break;
    default:
      await _generateDefaultPdf(pdf, data);
  }

  return pdf.save();
}

Future<void> _generateQuizPdf(
  pw.Document pdf,
  Map<String, dynamic> data,
) async {
  final List preguntas = data['preguntas'] ?? [];

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(16),
      build: (context) {
        return [
          _buildInstitutionalHeader(),
          pw.SizedBox(height: 16),
          _buildSectionTable('NOMBRE DEL ESTUDIANTE', ''),
          pw.SizedBox(height: 8),
          _buildSectionTable(
            'INSTRUCCIONES:',
            '• Lea cuidadosamente cada pregunta antes de responder.\n'
                '• Marque con una X la respuesta correcta.\n'
                '• Solo hay una respuesta correcta por pregunta.\n'
                '• No se permiten borrones ni enmendaduras.\n'
                '• Duración del quiz: ${data['duracion'] ?? 30} minutos.',
          ),
          pw.SizedBox(height: 8),
          _buildQuizQuestionsTable(preguntas),
          pw.SizedBox(height: 20),
          _buildObservationsSection(),
        ];
      },
    ),
  );
}

Future<void> _generateTallerPdf(
  pw.Document pdf,
  Map<String, dynamic> data,
) async {
  final String nombreTaller = data['nombreTaller'] ?? 'Taller';
  final String descripcionTaller = data['descripcionTaller'] ?? '';
  final String objetivoTaller = data['objetivoTaller'] ?? '';
  final List actividades = data['actividadesTaller'] ?? [];

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(16),
      build: (context) {
        return [
          _buildInstitutionalHeader(),
          pw.SizedBox(height: 16),
          _buildSectionTable('NOMBRE DEL TALLER', nombreTaller),
          pw.SizedBox(height: 8),
          _buildSectionTable(
            'ESTÁNDAR BÁSICO DE COMPETENCIAS (E.B.C)',
            descripcionTaller,
          ),
          pw.SizedBox(height: 8),
          _buildSectionTable(
            'DERECHOS BÁSICOS DE APRENDIZAJE (D.B.A):',
            objetivoTaller,
          ),
          pw.SizedBox(height: 8),
          _buildStrategiesSection(actividades),
        ];
      },
    ),
  );
}

Future<void> _generateExamenPdf(
  pw.Document pdf,
  Map<String, dynamic> data,
) async {
  final List preguntas = data['preguntas'] ?? [];
  final int duracion = data['duracion'] ?? 60;

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(16),
      build: (context) {
        return [
          _buildInstitutionalHeader(),
          pw.SizedBox(height: 16),
          _buildSectionTable('NOMBRE DEL ESTUDIANTE', ''),
          pw.SizedBox(height: 8),
          _buildSectionTable(
            'INSTRUCCIONES GENERALES:',
            '• Lea cuidadosamente todas las instrucciones antes de comenzar.\n'
                '• Responda todas las preguntas en el espacio asignado.\n'
                '• Use bolígrafo de tinta azul o negra.\n'
                '• No se permiten borrones, tachones o uso de corrector.\n'
                '• Duración del examen: $duracion minutos.\n'
                '• Entregue el examen completo al finalizar el tiempo.',
          ),
          pw.SizedBox(height: 8),
          _buildPointsDistributionTable(preguntas),
          pw.SizedBox(height: 8),
          _buildExamQuestionsTable(preguntas),
          pw.SizedBox(height: 20),
          _buildObservationsSection(),
        ];
      },
    ),
  );
}

Future<void> _generatePlanEstudioPdf(
  pw.Document pdf,
  Map<String, dynamic> data,
) async {
  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return [
          pw.Center(
            child: pw.Text(
              data['tituloCurso'] ?? 'Plan de Estudio',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          _buildInfoSection('Descripción', data['descripcionCurso'] ?? ''),
          _buildInfoSection('Nivel', data['nivel'] ?? ''),
          _buildInfoSection(
            'Duración Total',
            '${data['duracionTotal'] ?? 0} semanas',
          ),
          _buildInfoSection(
            'Número de Lecciones',
            '${data['numeroLecciones'] ?? 0}',
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Lecciones:',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          ...((data['lecciones'] ?? []) as List).map((leccion) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Lección ${leccion['numeroLeccion']}: ${leccion['tituloLeccion']}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text('Objetivo: ${leccion['objetivoLeccion']}'),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Duración: ${leccion['duracionLeccion'] ?? 30} minutos',
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Resumen: ${leccion['resumenLeccion']}'),
                ],
              ),
            );
          }).toList(),
        ];
      },
    ),
  );
}

Future<void> _generateDefaultPdf(
  pw.Document pdf,
  Map<String, dynamic> data,
) async {
  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Plantilla Generada',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Contenido: ${data.toString()}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        );
      },
    ),
  );
}


pw.Widget _buildInstitutionalHeader() {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
    child: pw.Column(
      children: [
        pw.Text(
          'I.E.: Institución Educativa Técnico Industrial Pedro Castro Monsalvo INSTPECAM',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'COORDINACIÓN DE PRÁCTICAS PEDAGÓGICAS Y FORMATIVAS',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          textAlign: pw.TextAlign.center,
        ),
      ],
    ),
  );
}

pw.Widget _buildSectionTable(String title, String content) {
  return pw.Table(
    border: pw.TableBorder.all(width: 1),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFE6E6)),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              title,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(content, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildQuizQuestionsTable(List preguntas) {
  return pw.Table(
    border: pw.TableBorder.all(width: 1),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFE6E6)),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'PREGUNTAS',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red,
              ),
            ),
          ),
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children:
                  preguntas.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> pregunta = entry.value;
                    final List opciones = pregunta['opciones'] ?? [];
                    final String respuestaCorrecta =
                        pregunta['respuestaCorrecta'] ?? '';

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${index + 1}. ${pregunta['pregunta'] ?? ''}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          ...opciones.map((opcion) {
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(
                                left: 16,
                                bottom: 4,
                              ),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 12,
                                    height: 12,
                                    margin: const pw.EdgeInsets.only(top: 2),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(),
                                    ),
                                  ),
                                  pw.SizedBox(width: 8),
                                  pw.Container(
                                    child: pw.Text(
                                      opcion.toString(),
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          if (respuestaCorrecta.isNotEmpty) ...[
                            pw.SizedBox(height: 8),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(6),
                              decoration: pw.BoxDecoration(
                                color: const PdfColor.fromInt(0xFFF0F8F0),
                                border: pw.Border.all(
                                  color: const PdfColor.fromInt(0xFF90EE90),
                                ),
                              ),
                              child: pw.Text(
                                'Respuesta correcta: $respuestaCorrecta',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildPointsDistributionTable(List preguntas) {
  return pw.Table(
    border: pw.TableBorder.all(width: 1),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFE6E6)),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'DISTRIBUCIÓN DE PUNTOS POR PREGUNTA',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Pregunta',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Puntos',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Obtenido',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Observación',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                ...preguntas.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> pregunta = entry.value;
                  int puntos = pregunta['puntos'] ?? 2;

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '${index + 1}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '$puntos',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Container(
                          height: 15,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Container(
                          height: 15,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildExamQuestionsTable(List preguntas) {
  return pw.Table(
    border: pw.TableBorder.all(width: 1),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFE6E6)),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'DESARROLLO DEL EXAMEN',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Wrap(
              // Cambiado Column por Wrap para evitar overflow
              direction: pw.Axis.vertical,
              spacing: 10,
              children:
                  preguntas.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> pregunta = entry.value;
                    final List opciones = pregunta['opciones'] ?? [];
                    final String tipoPregunta = pregunta['tipo'] ?? 'multiple';
                    final int puntos = pregunta['puntos'] ?? 2;
                    final String respuestaCorrecta =
                        pregunta['respuestaCorrecta'] ?? '';

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              color: const PdfColor.fromInt(0xFFF0F0F0),
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'PREGUNTA ${index + 1}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  'VALOR: $puntos puntos',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            '${pregunta['pregunta'] ?? ''}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 12),
                          if (tipoPregunta == 'multiple' &&
                              opciones.isNotEmpty) ...[
                            ...opciones.map((opcion) {
                              return pw.Container(
                                margin: const pw.EdgeInsets.only(
                                  left: 16,
                                  bottom: 6,
                                ),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Container(
                                      width: 15,
                                      height: 15,
                                      margin: const pw.EdgeInsets.only(top: 2),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(),
                                        borderRadius: pw.BorderRadius.circular(
                                          7.5,
                                        ),
                                      ),
                                    ),
                                    pw.SizedBox(width: 12),
                                    pw.Container(
                                      child: pw.Text(
                                        opcion.toString(),
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            if (respuestaCorrecta.isNotEmpty) ...[
                              pw.SizedBox(height: 8),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                decoration: pw.BoxDecoration(
                                  color: const PdfColor.fromInt(0xFFF0F8F0),
                                  border: pw.Border.all(
                                    color: const PdfColor.fromInt(0xFF90EE90),
                                  ),
                                ),
                                child: pw.Text(
                                  'Respuesta correcta: $respuestaCorrecta',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            pw.Container(
                              height: 60,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 0.5),
                              ),
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Espacio para la respuesta:',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                            if (respuestaCorrecta.isNotEmpty) ...[
                              pw.SizedBox(height: 8),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                decoration: pw.BoxDecoration(
                                  color: const PdfColor.fromInt(0xFFF0F8FF),
                                  border: pw.Border.all(
                                    color: const PdfColor.fromInt(0xFF87CEEB),
                                  ),
                                ),
                                child: pw.Text(
                                  'Respuesta esperada: $respuestaCorrecta',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildStrategiesSection(List actividades) {
  return pw.Table(
    border: pw.TableBorder.all(width: 1),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFE6E6)),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'ESTRATEGIAS DIDÁCTICAS Y METODOLÓGICAS (EJECUCIÓN DIDÁCTICA – ACCIONES PEDAGÓGICAS)',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INICIO/EXPLORACIÓN:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '✓ Saludo inicial ( bienvenida a los estudiantes)',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '✓ Formación de hábitos. (Organización del salón y que cada estudiante tome su lugar habitual.)',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'DESARROLLO/ESTRUCTURACIÓN:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                ...actividades
                    .take(3)
                    .map(
                      (actividad) => pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Text(
                          '✓ ${actividad['descripcionActividad'] ?? actividad['tituloActividad'] ?? ''}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    )
                    .toList(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'CIERRE/TRANSFERENCIA:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '✓ Espacio para resolver dudas e inquietudes que presenten los estudiantes.',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '✓ Los estudiantes deberán resolver una sopa de letras como actividad de cierre.',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildObservationsSection() {
  return pw.Table(
    border: pw.TableBorder.all(width: 1),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFE6E6)),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'OBSERVACIONES DEL DOCENTE:',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            height: 60,
            child: pw.Text(''),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildInfoSection(String title, String content) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$title: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Expanded(child: pw.Text(content)),
      ],
    ),
  );
}
