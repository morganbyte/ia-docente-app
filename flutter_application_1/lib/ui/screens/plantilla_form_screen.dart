import 'package:flutter/material.dart';
import '../../data/services/ia_service.dart'; // Asegúrate de que la ruta sea correcta

class TemplateFormScreen extends StatefulWidget {
  const TemplateFormScreen({super.key});

  @override
  _TemplateFormScreenState createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends State<TemplateFormScreen> {
  String _selectedTemplate = 'Examen';
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _numQuestionsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();

  bool _loading = false;

  Future<void> _generateTemplate() async {
    final topic = _topicController.text.trim();
    final difficulty = _difficultyController.text.trim();
    final duration = _durationController.text.trim();
    final numQuestions = int.tryParse(_numQuestionsController.text.trim()) ?? 5;

    if (topic.isEmpty) {
      _showDialog('Por favor, ingresa un tema.');
      return;
    }

    setState(() => _loading = true);

    try {
      // Construir el JSON dinámico
      Map<String, dynamic> request = {
        "model": "mistral",
        "tema": topic,
        "tipoPlantilla": _selectedTemplate.toLowerCase()
      };

      if (_selectedTemplate == 'Examen') {
        request["numeroPreguntas"] = numQuestions;
        request["dificultad"] = difficulty;
        request["duracion"] = duration;
      } else if (_selectedTemplate == 'Taller') {
        request["actividades"] = difficulty; // actividades ingresadas en el campo de dificultad
        request["duracion"] = duration;
      } else if (_selectedTemplate == 'Temario') {
        request["numeroLecciones"] = numQuestions;
      }

      // Enviar a la IA usando el servicio
      final response = await DeepSeekService().getDeepSeekResponse(
        topic,
        _selectedTemplate.toLowerCase(),
      );

      _showDialog(response);
    } catch (e) {
      _showDialog("Ocurrió un error al generar la plantilla:\n$e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Resultado"),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          )
        ],
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
            DropdownButton<String>(
              value: _selectedTemplate,
              onChanged: (value) => setState(() => _selectedTemplate = value!),
              items: <String>['Examen', 'Taller', 'Temario']
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Tema',
                hintText: 'Tema de la plantilla',
              ),
            ),
            const SizedBox(height: 16),

            // Campos condicionales según tipo
            if (_selectedTemplate == 'Examen') ...[
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
            ] else if (_selectedTemplate == 'Taller') ...[
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
                controller: _difficultyController,
                decoration: const InputDecoration(
                  labelText: 'Actividades',
                  hintText: 'Actividades del taller',
                ),
              ),
            ] else if (_selectedTemplate == 'Temario') ...[
              TextField(
                controller: _numQuestionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Lecciones',
                  hintText: 'Número de lecciones',
                ),
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _generateTemplate,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Generar Plantilla'),
            ),
          ],
        ),
      ),
    );
  }
}