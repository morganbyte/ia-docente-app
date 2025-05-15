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

  // Método para generar el JSON con los datos y enviarlo a la IA
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
          builder: (context) => TemplatePreviewScreen(jsonResponse: response, templateType: widget.templateType,),
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
      builder: (context) => TemplatePreviewScreen(jsonResponse: message, templateType: widget.templateType,),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Plantilla")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Tema',
                hintText: 'Tema de la plantilla',
              ),
            ),
            const SizedBox(height: 16),
            // Dependiendo del tipo de plantilla, muestra los campos correspondientes
            if (widget.templateType == 'Exámenes') ...[
              TextField(
                controller: _numQuestionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de preguntas',
                  hintText: 'Ej: 5',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración (minutos)',
                  hintText: 'Ej: 60',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _difficultyController,
                decoration: const InputDecoration(
                  labelText: 'Dificultad',
                  hintText: 'Fácil, media, difícil',
                ),
              ),
            ] else if (widget.templateType == 'Talleres') ...[
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración (horas)',
                  hintText: 'Ej: 2',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _numActivitiesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de actividades',
                  hintText: 'Ej: 3',
                ),
              ),
            ] else if (widget.templateType == 'Plan de Estudio') ...[
              TextField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Tema',
                  hintText: 'Tema del curso',
                ),
              ),
            ] else if (widget.templateType == 'Quizzes') ...[
              TextField(
                controller: _numQuestionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de preguntas',
                  hintText: 'Ej: 10',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración (minutos)',
                  hintText: 'Ej: 30',
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _generateTemplate,
              child:
                  _loading
                      ? const CircularProgressIndicator()
                      : const Text('Generar Plantilla'),
            ),
          ],
        ),
      ),
    );
  }
}
