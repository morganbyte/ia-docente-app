import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signUpWithEmail ({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );

      final user = credential.user;
      
      if (user != null) {
        await user.updateDisplayName(displayName);
        await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'email': user.email,
            'displayName': displayName,
            'createdAt': FieldValue.serverTimestamp(),
          });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> signInWithEmail ({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      await _registerUserInFirestore(userCredential.user);

      return userCredential.user;
    } catch (e) {
      print("Error durante el inicio de sesión con Google: $e");
      return null;
    }
  }

  Future<void> _registerUserInFirestore(User? user) async {
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      final doc = await userRef.get();
      if (!doc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'Sin nombre',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Función para cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
