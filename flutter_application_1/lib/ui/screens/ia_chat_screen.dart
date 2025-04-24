import 'package:flutter/material.dart';
import '../../data/services/ia_service.dart';
import '../../ui/screens/historial_screen.dart';

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
      final reply = await _openAIService.getOpenAIResponse(prompt);
      setState(() {
        _messages.add({'tipo': 'bot', 'mensaje': reply});
      });
      await Future.delayed(const Duration(milliseconds: 200));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
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
      body: SafeArea(
        child: Column(
          children: [
            // 1) Zona superior: o bien saludo centrado, o bien ListView del chat
            Expanded(
              child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Hola profesor, ¿en qué puedo ayudarte hoy?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Caja de texto en el centro
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Envía tu solicitud',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: _loading ? null : _sendMessage,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Botones rápidos centrados
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                //_controller.text = 'Generar un temario sobre Dart';
                              },
                              child: const Text('Temario'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                //_controller.text = 'Crear evaluaciones Flutter';
                              },
                              child: const Text('Evaluaciones'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final msg = _messages[i];
                      final isUser = msg['tipo']=='user';
                      return Align(
                        alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                              ? Colors.deepPurple.shade100
                              : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg['mensaje']!),
                        ),
                      );
                    },
                  ),
            ),

            // 2) Caja de entrada fija bajo la conversación (si ya hay mensajes)
            if (_messages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Envía tu solicitud',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _loading ? null : _sendMessage,
                    ),
                  ],
                ),
              ),

            // 3) Indicador de carga
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),

      // 4) BottomNavigationBar siempre presente
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const HistorialScreen()));
          }
          // manejar i==2 → Plantillas...
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.view_module), label: 'Plantillas'),
        ],
      ),
    );
  }
}
