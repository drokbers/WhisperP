import 'package:firebase_auth/firebase_auth.dart';

extension UserExt on User {
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'emailVerified': emailVerified,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }
}
