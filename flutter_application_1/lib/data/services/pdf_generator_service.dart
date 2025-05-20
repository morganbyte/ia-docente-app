import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndPrintPdf(
  Map<String, dynamic> data,
  String templateType,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Plantilla Generada',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Título:',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              data['tituloQuiz'] ??
                  data['nombreTaller'] ??
                  data['tituloExamen'] ??
                  'Título no disponible',
            ),
            pw.SizedBox(height: 16),

            if (templateType == 'Exámenes' || templateType == 'Quizzes') ...[
              pw.Text(
                'Preguntas:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              ...((data['preguntas'] ?? []) as List).map((preg) {
                final opciones = (preg['opciones'] ?? []) as List;
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Pregunta ${preg['numeroPregunta']}: ${preg['pregunta']}',
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Opciones:'),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: opciones.map((o) => pw.Text('- $o')).toList(),
                    ),
                    pw.Text('Respuesta correcta: ${preg['respuestaCorrecta']}'),
                    pw.SizedBox(height: 12),
                  ],
                );
              }),
            ],
          ],
        );
      },
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
