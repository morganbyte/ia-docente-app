import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/screens/login_screen.dart';

import '../../data/services/ia_service.dart';


class IaChatScreen extends StatefulWidget {
  const IaChatScreen({super.key});

  @override
  State<IaChatScreen> createState() => _IaChatScreenState();
}

class _IaChatScreenState extends State<IaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _deepSeekService = DeepSeekService();

  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _messages = [];
  bool _loading = false;

  void _sendMessage() async {
    final prompt = _controller.text.trim();
    final tipoPlantilla = _controller.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _loading = true;
      _messages.add({'tipo': 'user', 'mensaje': prompt});
    });

    try {
      final reply = await _deepSeekService.getDeepSeekResponse(prompt, tipoPlantilla);

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

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AuthenticationPage()),
      (route) => false,
    );
  }

  @override
Widget build(BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0F0F2C), Color(0xFF1F1F3C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: SafeArea(
      child: Column(
        children: [
          // AppBar personalizado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "🤖 Chat con IA",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Cerrar sesión',
                  onPressed: _logout,
                ),
              ],
            ),
          ),

          // Zona del chat
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
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInputBox(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _futuristicButton("Temario"),
                            const SizedBox(width: 12),
                            _futuristicButton("Evaluaciones"),
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
                      final isUser = msg['tipo'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blueAccent.shade200.withOpacity(0.2) : Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            msg['mensaje']!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_messages.isNotEmpty) _buildInputBox(),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(
                color: Colors.cyanAccent,
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildInputBox() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _sendMessage(),
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.cyanAccent),
          onPressed: _loading ? null : _sendMessage,
        ),
      ],
    ),
  );
}

Widget _futuristicButton(String label) {
  return ElevatedButton(
    onPressed: () {
      _controller.text = label == 'Temario'
          ? 'Generar un temario sobre Flutter'
          : 'Crear evaluaciones para Dart';
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.cyanAccent,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

}
