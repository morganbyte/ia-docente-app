import 'package:flutter/material.dart';

class QuizFormat extends StatelessWidget {
  final List<dynamic> preguntas;
  final int currentIndex;
  final String templateType;
  final Map<int, String> selectedAnswers;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Function(String) onAnswerSelected;

  const QuizFormat({
    super.key,
    required this.preguntas,
    required this.currentIndex,
    required this.templateType,
    required this.selectedAnswers,
    required this.onPrevious,
    required this.onNext,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (preguntas.isEmpty) {
      return const Center(
        child: Text(
          'No hay preguntas disponibles.',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      );
    }

    final preguntaActual = preguntas[currentIndex];
    final opciones = preguntaActual['opciones'] ?? [];
    final estaSeleccionada = (String opcion) => selectedAnswers[currentIndex] == opcion;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildQuestionCounter(),
          const SizedBox(height: 24),
          _buildQuestionBox(preguntaActual['pregunta'] ?? ''),
          const SizedBox(height: 20),
          ...opciones.asMap().entries.map((entry) => _buildOption(entry.key, entry.value.toString(), estaSeleccionada(entry.value.toString()))).toList(),
          const SizedBox(height: 32),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'INSTPECAM',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'I.E. Técnico Industrial Pedro Castro Monsalvo',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Coordinación de Prácticas Pedagógicas',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCounter() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: templateType == 'Quizzes' ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: templateType == 'Quizzes' ? const Color(0xFFD1FAE5) : const Color(0xFFDBEAFE),
              width: 1,
            ),
          ),
          child: Text(
            '${currentIndex + 1} de ${preguntas.length}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: templateType == 'Quizzes' ? const Color(0xFF059669) : const Color(0xFF0284C7),
            ),
          ),
        ),
        const Spacer(),
        Text(
          templateType == 'Quizzes' ? 'Quiz' : 'Examen',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBox(String pregunta) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Text(
        pregunta,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.6,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildOption(int index, String opcion, bool seleccionada) {
    final letra = String.fromCharCode(65 + index);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: seleccionada ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: seleccionada
              ? (templateType == 'Quizzes' ? const Color(0xFF059669) : const Color(0xFF0284C7))
              : const Color(0xFFE2E8F0),
          width: seleccionada ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onAnswerSelected(opcion),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: seleccionada
                        ? (templateType == 'Quizzes' ? const Color(0xFF059669) : const Color(0xFF0284C7))
                        : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: seleccionada ? Colors.transparent : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letra,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: seleccionada ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    opcion,
                    style: TextStyle(
                      fontSize: 15,
                      color: seleccionada ? const Color(0xFF1E293B) : const Color(0xFF475569),
                      fontWeight: seleccionada ? FontWeight.w500 : FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (currentIndex > 0)
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Anterior', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        if (currentIndex > 0) const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: templateType == 'Quizzes' ? const Color(0xFF059669) : const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF94A3B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                currentIndex < preguntas.length - 1 ? 'Siguiente' : 'Finalizar',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}