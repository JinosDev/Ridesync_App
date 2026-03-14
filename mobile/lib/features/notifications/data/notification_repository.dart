import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_model.dart';

class NotificationRepository {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<List<NotificationModel>> watchNotifications() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromJson({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<void> markAsRead(String notifId) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('notifications').doc(uid).collection('items').doc(notifId).update({'isRead': true});
  }
}

final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});
