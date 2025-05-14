import 'package:flutter/material.dart';
import 'template_form_screen.dart';

class PlantillaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar Plantilla')),
      body: ListView(
        children: [
          _buildPlantillaOption(context, 'Talleres'),
          _buildPlantillaOption(context, 'Plan de estudio'),
          _buildPlantillaOption(context, 'Quizzes'),
          _buildPlantillaOption(context, 'Exámenes'),
        ],
      ),
    );
  }

  Widget _buildPlantillaOption(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemplateFormScreen(templateType: label),
            ),
          );
        },
        child: Text(label),
      ),
    );
  }
}
