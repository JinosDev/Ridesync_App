import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_model.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  /// Fetch current user's Firestore profile
  Future<UserModel?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson({'uid': doc.id, ...doc.data()!});
  }

  /// Update FCM token on each app open
  Future<void> updateFcmToken(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }
}
