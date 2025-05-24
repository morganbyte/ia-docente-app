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

  final Color _buttonColor = const Color(0xFFf6f343); 
  final Color _buttonTextColor = Colors.black;
  final Color _googleButtonColor = Colors.black87;

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: false,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
    );
  }

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
    // Puedes agregar más casos personalizados aquí
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _buttonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.star, color: Colors.black, size: 20),
                ),
                const SizedBox(height: 24),

                Text(
                  _isLogin ? "Bienvenido a EducaPro" : "Bienvenido a EducaPro",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  _isLogin
                      ? "Ingresa los siguientes campos para iniciar sesión"
                      : "Crea una cuenta, tomará unos segundos. Ingresa los siguientes campos",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                if (!_isLogin) ...[
                  TextField(
                    controller: _displayNameCtrl,
                    decoration: _inputStyle("Nombre"),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputStyle("Correo"),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: _inputStyle("Contraseña"),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor,
                      foregroundColor: _buttonTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            _isLogin ? "Ingresar" : "Empezar",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "o",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _googleLogin,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text(
                      "Continuar con Google",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _googleButtonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Center(
                  child: Wrap(
                    children: [
                      Text(
                        _isLogin
                            ? "¿Aún no tienes cuenta?. "
                            : "Si ya tienes una cuenta. ",
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
