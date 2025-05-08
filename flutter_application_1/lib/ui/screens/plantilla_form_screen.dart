import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlantillaFormScreen extends StatefulWidget {
  final String tipoPlantilla;
  PlantillaFormScreen({required this.tipoPlantilla});

  @override
  _PlantillaFormScreenState createState() => _PlantillaFormScreenState();
}

class _PlantillaFormScreenState extends State<PlantillaFormScreen> {
  final TextEditingController _temaController = TextEditingController();
  final TextEditingController _numeroPreguntasController =
      TextEditingController();
  final TextEditingController _dificultadController = TextEditingController();
  String? PlantillaData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generar ${widget.tipoPlantilla}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _temaController,
              decoration: InputDecoration(
                labelText: 'Ingresa el tema',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _numeroPreguntasController,
              decoration: InputDecoration(
                labelText: 'Ingresa la cantidad de preguntas',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendDataToAI();
              },
              child: Text('Generar ${widget.tipoPlantilla}'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendDataToAI() async {
    final prompt = _temaController.text.trim();
    final numeroPreguntas =
        int.tryParse(_numeroPreguntasController.text.trim()) ?? 5;
    final dificultad = _dificultadController.text.trim();

    if (prompt.isEmpty) {
      return;
    }

    Map<String, dynamic> requestData = {
      'templateType': widget.tipoPlantilla,
      'topic': prompt,
    };

    final response = await http.post(
      Uri.parse('https://api.deepseek.com/generateTemplate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      setState(() {
        PlantillaData = response.body;
      });
      // Mostrar la plantilla generada
      _showGeneratedTemplate(PlantillaData!);
    } else {
      print('Error al generar plantilla');
    }
  }

  void _showGeneratedTemplate(String plantilla) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Plantilla Generada'),
            content: Text(plantilla),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}
