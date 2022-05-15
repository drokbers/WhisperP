import 'package:firebase_auth/firebase_auth.dart';

extension UserExt on User {
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'emailVerified': emailVerified,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }
}
