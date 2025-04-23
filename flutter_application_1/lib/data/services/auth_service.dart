import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

        // aquí creamos la credencial de autenticación para Firebas
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // autenticamos al usuario con Firebase
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
    } catch (e) {
      print("Error durante el inicio de sesión con Google: $e");
      return null;
    } 
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
