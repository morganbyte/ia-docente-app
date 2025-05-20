import 'package:flutter/material.dart';
import 'dart:convert';

class DetallePlantillaScreen extends StatelessWidget {
  final Map<String, dynamic> plantillaData;

  const DetallePlantillaScreen({super.key, required this.plantillaData});

  @override
  Widget build(BuildContext context) {
    final prompt = plantillaData['prompt'] ?? 'Sin solicitud';
    final respuesta = plantillaData['respuesta'] ?? 'Sin contenido';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Plantilla"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cuadro azul con la solicitud (prompt)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prompt,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            // Texto con la respuesta formateada
            SelectableText(
              _formatJson(respuesta),
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatJson(String input) {
    try {
      final decoded = jsonDecode(input);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return input; // Mostrar como texto plano si no es JSON válido
    }
  }
}


