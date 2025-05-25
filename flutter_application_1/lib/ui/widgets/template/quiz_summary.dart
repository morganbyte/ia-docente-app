import 'package:flutter/material.dart';

class QuizSummary extends StatelessWidget {
  final String templateType;
  final List<Map<String, dynamic>> preguntas;
  final Map<int, String> selectedAnswers;
  final VoidCallback onRetry;

  const QuizSummary({
    super.key,
    required this.templateType,
    required this.preguntas,
    required this.selectedAnswers,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    int correctas = 0;
    List<Map<String, dynamic>> resultados = [];

    preguntas.asMap().forEach((index, pregunta) {
      String respuestaUsuario = selectedAnswers[index] ?? '';
      String respuestaCorrecta = pregunta['respuestaCorrecta'] ?? '';
      bool esCorrecta = respuestaUsuario == respuestaCorrecta;

      if (esCorrecta) correctas++;

      resultados.add({
        'pregunta': pregunta['pregunta'] ?? '',
        'respuestaUsuario': respuestaUsuario,
        'respuestaCorrecta': respuestaCorrecta,
        'esCorrecta': esCorrecta,
        'opciones': pregunta['opciones'] ?? [],
      });
    });

    double porcentaje = (correctas / preguntas.length) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: porcentaje >= 70
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF3C7),
                  ),
                  child: Icon(
                    porcentaje >= 70 ? Icons.check_circle : Icons.info,
                    size: 40,
                    color: porcentaje >= 70
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$templateType Completado',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$correctas de ${preguntas.length} correctas',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: porcentaje >= 70
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${porcentaje.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: porcentaje >= 70
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Revisión de Respuestas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          ...resultados.asMap().entries.map((entry) {
            final index = entry.key;
            final resultado = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: resultado['esCorrecta']
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFECDD3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: resultado['esCorrecta']
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF2F2),
                          ),
                          child: Icon(
                            resultado['esCorrecta']
                                ? Icons.check
                                : Icons.close,
                            color: resultado['esCorrecta']
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pregunta ${index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      resultado['pregunta'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (resultado['respuestaUsuario'].isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: resultado['esCorrecta']
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tu respuesta: ${resultado['respuestaUsuario']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: resultado['esCorrecta']
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (!resultado['esCorrecta']) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Respuesta correcta: ${resultado['respuestaCorrecta']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: templateType == 'Quizzes'
                    ? const Color(0xFF059669)
                    : const Color(0xFF0284C7),
                side: BorderSide(
                  color: templateType == 'Quizzes'
                      ? const Color(0xFF059669)
                      : const Color(0xFF0284C7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
