import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument ({
    required String uid,
    required String? email,
    required String? displayName,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    await userRef.set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureUserDocumentExists(User? user) async {
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
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
}