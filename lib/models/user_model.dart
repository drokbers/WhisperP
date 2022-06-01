import 'package:cloud_firestore/cloud_firestore.dart';

import '../consts/index.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String photoURL;
  final String email;
  final DateTime registerationTime;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.photoURL,
    required this.email,
    required this.registerationTime,
  });

  factory UserModel.fromMap(final Map map) {
    return UserModel(
      uid: map["uid"],
      displayName: map["displayName"] ?? "",
      photoURL: map["photoURL"] ?? Str.dummyProfilePhotoUrl,
      email: map["email"],
      registerationTime: map["registerationTime"] is Timestamp
          ? map["registerationTime"].toDate()
          : map["registerationTime"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "displayName": displayName,
      "photoURL": photoURL,
      "email": email,
      "registerationTime": registerationTime,
    };
  }

  @override
  String toString() => "$displayName $email";
}
