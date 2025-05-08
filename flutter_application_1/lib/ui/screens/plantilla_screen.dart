import 'package:flutter/material.dart';
import './plantilla_form_screen.dart';

class PlantillaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar Plantilla')),
      body: ListView(
        children: [
          _buildPlantillaOption(context, 'Temarios', 'temario'),
          _buildPlantillaOption(context, 'Talleres', 'taller'),
          _buildPlantillaOption(context, 'Exámenes', 'examen'),
          _buildPlantillaOption(context, 'Quizzes', 'quiz'),
          _buildPlantillaOption(context, 'Planes de Estudio', 'planEstudio'),
        ],
      ),
    );
  }

  Widget _buildPlantillaOption(
    BuildContext context,
    String label,
    String templateType,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PlantillaFormScreen(tipoPlantilla: templateType),
            ),
          );
        },
        child: Text(label),
      ),
    );
  }
}
