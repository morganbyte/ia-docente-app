import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/screens/plantilla_screen.dart';
import '../../data/services/auth_service.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});
  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _authService = Authentication();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      User? user;
      if (_isLogin) {
        // Login
        user = await _authService.signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        // Registro
        user = await _authService.signUpWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          displayName: _displayNameCtrl.text.trim(),
        );
      }

      if (user != null) {
        // Redirigir al chat o la pantalla principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PlantillaScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
      });

      String errorMessage = '';

      // Manejamos casos de errores comunes
      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              'El usuario no existe. Verifica el correo y vuelve a intentarlo.';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta. Intenta de nuevo.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo no es válido. Ingresa un correo correcto.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Este correo ya está registrado. Intenta con otro.';
          break;
        case 'weak-password':
          errorMessage =
              'La contraseña es demasiado débil. Usa al menos 6 caracteres.';
          break;
        default:
          errorMessage = 'Hubo un error desconocido. Intenta nuevamente.';
          break;
      }

      // Mostrar error con SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });

      // Para errores no relacionados con Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error desconocido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _loading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PlantillaScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text("EducaPro IA")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToggleButtons(
                isSelected: [_isLogin, !_isLogin],
                onPressed: (i) {
                  setState(() {
                    _isLogin = i == 0;
                    _error = null;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Ingresar"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Registrarse"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Correo"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña"),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : Text(_isLogin ? "Ingresar" : "Crear cuenta"),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _googleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text("Continuar con Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
