import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../extensions/user_ext.dart';

class FirestoreUserRegisteration {
  final _firestore = FirebaseFirestore.instance;

  Future<void> checkUserIfRegisterated(User? user) async {
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      if (userDoc.data()!['displayName'] == user.displayName) {
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'displayName': user.displayName,
      });
      return;
    }

    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }
}
