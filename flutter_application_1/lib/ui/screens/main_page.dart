import 'package:flutter/material.dart';
import 'ia_chat_screen.dart';
import 'historial_screen.dart';
import 'plantilla_screen.dart'; // Descomenta si ya tienes esta clase

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    IaChatScreen(),
    HistorialScreen(tipo: "",),
    PlantillaScreen(), 
  ];

  void _onItemTapped(int index) {
  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistorialScreen(tipo: 'plantillas'),
      ),
    );
  } else {
    setState(() {
      _selectedIndex = index;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.view_module), label: 'Plantillas'),
        ],
      ),
    );
  }
}
