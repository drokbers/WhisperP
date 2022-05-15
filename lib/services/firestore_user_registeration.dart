import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../extensions/user_ext.dart';

class FirestoreUserRegisteration {
  final _firestore = FirebaseFirestore.instance;

  Future<void> checkUserIfRegisterated(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) return;

    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }
}
