import 'package:flutter/material.dart';
import '../../data/services/ia_service.dart';

class IaChatScreen extends StatefulWidget {
  const IaChatScreen({super.key});

  @override
  State<IaChatScreen> createState() => _IaChatScreenState();
}

class _IaChatScreenState extends State<IaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _openAIService = OpenAIService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _messages = [];
  bool _loading = false;

  void _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _loading = true;
      _messages.add({'tipo': 'user', 'mensaje': prompt});
    });

    try {
      final result = await _openAIService.getOpenAIResponse(prompt);
      setState(() {
        _messages.add({'tipo': 'bot', 'mensaje': result});
      });

      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      setState(() {
        _messages.add({'tipo': 'bot', 'mensaje': '❌ Error: $e'}); 
      });
    } finally {
      setState(() {
        _loading = false;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Hola profesor, ¿en qué puedo ayudarte el día de hoy?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Envía tu solicitud',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _loading ? null : _sendMessage,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.text = 'Generar un temario sobre programación en Dart';
                    });
                    _sendMessage();
                  },
                  child: const Text('Generador de temario'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.text = 'Crear evaluación para estudiantes de Flutter';
                    });
                    _sendMessage();
                  },
                  child: const Text('Crear evaluaciones'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.text = '¿Qué más puedo hacer con esta app?';
                    });
                    _sendMessage();
                  },
                  child: const Text('Más'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final mensaje = _messages[index];
                  final isUser = mensaje['tipo'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(mensaje['mensaje'] ?? ''),
                    ),
                  );
                },
              ),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.view_module), label: 'Plantillas'),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Ayuda'),
                content: const Text('Puedes escribir tu solicitud o usar los botones para generar contenido educativo.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  )
                ],
              ),
            );
          },
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.help_outline, color: Colors.black),
        ),
      ),
    );
  }
}
