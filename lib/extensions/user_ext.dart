import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

extension UserExt on User {
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'emailVerified': emailVerified,
      'displayName': displayName,
      'photoURL': photoURL,
      'registerationTime': FieldValue.serverTimestamp(),
    };
  }
}
