import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressFirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProgressFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid;
  }

  Future<Map<String, dynamic>> loadProgress(String tallerId) async {
    final userId = await getCurrentUserId();
    if (userId == null) return {};

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('talleresProgreso')
          .doc(tallerId)
          .get();

      if (!doc.exists) return {};

      return doc.data() ?? {};
    } catch (e) {
      print('Error al cargar progreso: $e');
      return {};
    }
  }

  Future<void> saveProgress({
    required String tallerId,
    required Map<int, bool> completedActivities,
    required Map<int, String?> activityNotes,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final actividadesCompletadasMap = completedActivities.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    final notasMap = activityNotes.map(
      (key, value) => MapEntry(key.toString(), value ?? ''),
    );

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('talleresProgreso')
          .doc(tallerId)
          .set({
        'actividadesCompletadas': actividadesCompletadasMap,
        'notasActividades': notasMap,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar progreso: $e');
    }
  }
}
