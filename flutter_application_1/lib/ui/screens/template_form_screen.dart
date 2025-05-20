import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/screens/template_preview_screen.dart';
import '../../data/services/ia_service.dart';

class TemplateFormScreen extends StatefulWidget {
  final String templateType; // Recibimos el tipo de plantilla seleccionado

  const TemplateFormScreen({super.key, required this.templateType});

  @override
  _TemplateFormScreenState createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends State<TemplateFormScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _numQuestionsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _numActivitiesController =
      TextEditingController();

  bool _loading = false;

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: TextStyle(color: Colors.grey[500]),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _generateTemplate() async {
    final topic = _topicController.text.trim();
    final difficulty = _difficultyController.text.trim();
    final duration = _durationController.text.trim();
    final numQuestions = int.tryParse(_numQuestionsController.text.trim()) ?? 5;
    final numActivities =
        int.tryParse(_numActivitiesController.text.trim()) ?? 0;

    if (topic.isEmpty) {
      _showDialog('Por favor, ingresa un tema.');
      return;
    }

    setState(() => _loading = true);

    try {
      final request = {
        "model": "mistral",
        "tipoPlantilla": widget.templateType,
        "tema": topic,
      };

      if (widget.templateType == 'Exámenes') {
        request["numeroPreguntas"] = numQuestions.toString();
        request["duracion"] = duration;
        request["dificultad"] = difficulty;
      } else if (widget.templateType == 'Talleres') {
        request["duracion"] = duration;
        request["numeroActividades"] = numActivities.toString();
      } else if (widget.templateType == 'Plan de estudio') {
      } else if (widget.templateType == 'Quizzes') {
        request["numeroPreguntas"] = numQuestions.toString();
        request["duracion"] = duration;
      }

      final response = await DeepSeekService().getDeepSeekResponseFromRequest(
        request,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TemplatePreviewScreen(
                jsonResponse: response,
                templateType: widget.templateType,
              ),
        ),
      );
    } catch (e) {
      _showDialog("Ocurrió un error al generar la plantilla:\n$e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showDialog(String message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TemplatePreviewScreen(
              jsonResponse: message,
              templateType: widget.templateType,
            ),
      ),
    );
  }

  void _clearFields() {
    _topicController.clear();
    _numQuestionsController.clear();
    _durationController.clear();
    _difficultyController.clear();
    _numActivitiesController.clear();

    FocusScope.of(context).unfocus(); // Cierra el teclado si está abierto
  }

  @override
  Widget build(BuildContext context) {
    final plantillaTipoCapitalizada =
        widget.templateType.isNotEmpty
            ? "${widget.templateType[0].toUpperCase()}${widget.templateType.substring(1)}"
            : '';
    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Text(
            'Crear plantilla para $plantillaTipoCapitalizada',
            style: const TextStyle(fontSize: 18),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: _inputDecoration('Tema', 'Tema de la plantilla'),
            ),
            const SizedBox(height: 20),

            if (widget.templateType == 'Exámenes') ...[
              TextField(
                controller: _numQuestionsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Número de preguntas', 'Ej: 5'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Duración (minutos)', 'Ej: 60'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _difficultyController,
                decoration: _inputDecoration(
                  'Dificultad',
                  'Fácil, media, difícil',
                ),
              ),
            ] else if (widget.templateType == 'Talleres') ...[
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Duración (horas)', 'Ej: 2'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _numActivitiesController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Número de actividades', 'Ej: 3'),
              ),
            ] else if (widget.templateType == 'Plan de estudio')
              ...[
            ] else if (widget.templateType == 'Quizzes') ...[
              TextField(
                controller: _numQuestionsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Número de preguntas', 'Ej: 10'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Duración (minutos)', 'Ej: 30'),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _generateTemplate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:
                    _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Generar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _clearFields,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors
                          .deepPurpleAccent, // mismo color que el botón generar
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                ),
                child: const Text(
                  'Nueva Plantilla',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
