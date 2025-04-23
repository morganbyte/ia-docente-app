import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/screens/ia_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final Authentication _authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Iniciar sesión"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await _authentication.signInWithGoogle();
            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IaChatScreen()),
                );
            } else {
              print("Error al iniciar sesión");
            }
          },
          child: Text("Iniciar sesión con Google"),
        ),
      ),
    );
  }
}
