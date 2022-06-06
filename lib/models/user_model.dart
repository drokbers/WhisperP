import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../consts/index.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String displayName;
  @HiveField(2)
  final String photoURL;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final DateTime registerationTime;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.photoURL,
    required this.email,
    required this.registerationTime,
  });

  factory UserModel.fromMap(final Map map, {String? uid}) {
    return UserModel(
      uid: uid ?? map["uid"] ?? "uid-not-assigned",
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
