import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/screens/plantilla_screen.dart';
import '../../data/services/authentication_service.dart';

import '../widgets/auth_header.dart';
import '../widgets/auth_input_fields.dart';
import '../widgets/main_auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/google_auth_button.dart';

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

  final Color _buttonColor = const Color(0xFFf6f343);
  final Color _buttonTextColor = Colors.black;
  final Color _googleButtonColor = Colors.black87;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent.withOpacity(0.85),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
    });

    try {
      User? user;
      if (_isLogin) {
        user = await _authService.signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        user = await _authService.signUpWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          displayName: _displayNameCtrl.text.trim(),
        );
      }

      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PlantillaScreen()),
        );
      }
    } catch (e) {
      _showErrorSnackBar(_parseErrorMessage(e));
    } finally {
      setState(() => _loading = false);
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
      _showErrorSnackBar(_parseErrorMessage(e));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _parseErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuario no encontrado.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'invalid-email':
          return 'Correo no válido.';
        case 'email-already-in-use':
          return 'Correo ya en uso.';
        case 'weak-password':
          return 'Contraseña débil.';
        default:
          return 'Error inesperado.';
      }
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthHeader( 
                  isLogin: _isLogin,
                  buttonColor: _buttonColor,
                ),
                AuthInputFields( 
                  isLogin: _isLogin,
                  displayNameCtrl: _displayNameCtrl,
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                ),
                MainAuthButton( 
                  loading: _loading,
                  isLogin: _isLogin,
                  onSubmit: _submit,
                  buttonColor: _buttonColor,
                  buttonTextColor: _buttonTextColor,
                ),
                const AuthDivider(), 
                GoogleAuthButton( 
                  loading: _loading,
                  onGoogleLogin: _googleLogin,
                  googleButtonColor: _googleButtonColor,
                ),
                const SizedBox(height: 32),
                Center(
                  child: Wrap(
                    children: [
                      Text(
                        _isLogin ? "¿Aún no tienes cuenta?. " : "Si ya tienes una cuenta. ",
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin ? "Crear una" : "Ingresar", 
                          style: const TextStyle(
                            color: Color(0xFFf6f343),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}