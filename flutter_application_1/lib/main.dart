import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/screens/ia_chat_screen.dart';

import 'ui/screens/login_screen.dart';
//import 'ui/screens/ia_chat_screen.dart';
import 'ui/screens/historial_screen.dart';
import 'ui/screens/plantilla_screen.dart';
// Si ya tienes pantalla de plantillas, importa aquí:
// import 'ui/screens/plantillas_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EducaPro IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const _AuthGate(),
      routes: {
        '/login': (_) => AuthenticationPage(),
        '/chat': (_) =>  IaChatScreen(),
        '/historial': (_) => const HistorialScreen(),
        '/plantillas': (_) => PlantillaScreen(),
      },
    );
  }
}

/// Esta clase decide qué pantalla mostrar según el estado de autenticación.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras carga la info de Firebase:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Si NO hay usuario, vamos a login:
        if (!snapshot.hasData) {
          return AuthenticationPage();
        }
        // Si hay usuario, vamos al chat:
        return IaChatScreen();
      },
    );
  }
}
