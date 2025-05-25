import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/screens/template_preview_screen.dart';
import 'package:flutter_application_1/data/services/gemini_service.dart';
import 'package:flutter_application_1/config/app_colors.dart'; 
import 'package:flutter_application_1/ui/widgets/custom_text_field.dart'; 

class TemplateFormScreen extends StatefulWidget {
  final String templateType; 

  const TemplateFormScreen({super.key, required this.templateType});

  @override
  _TemplateFormScreenState createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends State<TemplateFormScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _numQuestionsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _numActivitiesController = TextEditingController();
  final TextEditingController _numLeccionesController = TextEditingController();

  bool _loading = false;


  Future<void> _generateTemplate() async {
    final topic = _topicController.text.trim();
    final difficulty = _difficultyController.text.trim();
    final duration = _durationController.text.trim();
    final numQuestions = int.tryParse(_numQuestionsController.text.trim()) ?? 5;
    final numActivities = int.tryParse(_numActivitiesController.text.trim()) ?? 0;
    final numLecciones = int.tryParse(_numLeccionesController.text.trim()) ?? 0;

    if (topic.isEmpty) {
      _showDialog('Por favor, ingresa un tema.');
      return;
    }

    setState(() => _loading = true);

    try {
      final request = {
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
      } else if (widget.templateType == 'Temario') {
        request["duracion"] = duration;
        request["numeroLecciones"] = numLecciones.toString();
      } else if (widget.templateType == 'Quizzes') {
        request["numeroPreguntas"] = numQuestions.toString();
        request["duracion"] = duration;
      }

      final response = await GeminiService().getGeminiResponseFromRequest(
        request,
      );

      if (response.isEmpty) {
         _showDialog("La respuesta de Gemini está vacía o es inválida.");
         return;
      }


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TemplatePreviewScreen(
            jsonResponse: response,
            templateType: widget.templateType,
          ),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Ocurrió un error al generar la plantilla:\n$e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Alerta'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _topicController.clear();
    _numQuestionsController.clear();
    _durationController.clear();
    _difficultyController.clear();
    _numActivitiesController.clear();
    _numLeccionesController.clear(); 

    FocusScope.of(context).unfocus(); 
  }

  @override
  void dispose() {
    _topicController.dispose();
    _numQuestionsController.dispose();
    _durationController.dispose();
    _difficultyController.dispose();
    _numActivitiesController.dispose();
    _numLeccionesController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantillaTipoCapitalizada =
        widget.templateType.isNotEmpty
            ? "${widget.templateType[0].toUpperCase()}${widget.templateType.substring(1)}"
            : '';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear plantilla para $plantillaTipoCapitalizada',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18, 
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark, 
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            CustomTextField( 
              controller: _topicController,
              label: 'Tema',
              hint: 'Tema de la plantilla',
            ),
            const SizedBox(height: 20),

            if (widget.templateType == 'Exámenes') ...[
              CustomTextField(
                controller: _numQuestionsController,
                keyboardType: TextInputType.number,
                label: 'Número de preguntas',
                hint: 'Ej: 5',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                label: 'Duración (minutos)',
                hint: 'Ej: 60',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _difficultyController,
                label: 'Dificultad',
                hint: 'Fácil, media, difícil',
              ),
            ] else if (widget.templateType == 'Talleres') ...[
              CustomTextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                label: 'Duración (horas)',
                hint: 'Ej: 2',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _numActivitiesController,
                keyboardType: TextInputType.number,
                label: 'Número de actividades',
                hint: 'Ej: 3',
              ),
            ] else if (widget.templateType == 'Temario') ...[
              CustomTextField(
                controller: _numLeccionesController,
                keyboardType: TextInputType.number,
                label: 'Número de lecciones',
                hint: 'Ej: 3',
              ),
            ] else if (widget.templateType == 'Quizzes') ...[
              CustomTextField(
                controller: _numQuestionsController,
                keyboardType: TextInputType.number,
                label: 'Número de preguntas',
                hint: 'Ej: 10',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                label: 'Duración (minutos)',
                hint: 'Ej: 30',
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _generateTemplate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Generar',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith( 
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
                  backgroundColor: AppColors.accent2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.accent2.withOpacity(0.5), 
                ),
                child: Text(
                  'Nueva Plantilla',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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