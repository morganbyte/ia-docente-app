import 'package:flutter/material.dart';
import 'dart:convert';

class DetallePlantillaScreen extends StatelessWidget {
  final Map<String, dynamic> plantillaData;

  const DetallePlantillaScreen({super.key, required this.plantillaData});

  @override
  Widget build(BuildContext context) {
    final dynamic respuesta = plantillaData['respuesta'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Plantilla"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: respuesta == null
            ? const Text('Sin contenido')
            : SelectableText(
                _formatJson(respuesta),
                style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
              ),
      ),
    );
  }

  String _formatJson(dynamic input) {
    try {
      if (input is String) {
        final decoded = jsonDecode(input);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(decoded);
      } else if (input is Map<String, dynamic> || input is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(input);
      } else {
        return input.toString();
      }
    } catch (_) {
      return input.toString(); // Mostrar como texto plano si no es JSON válido
    }
  }
}

