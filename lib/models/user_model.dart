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
  final int registerationMS;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.photoURL,
    required this.email,
    required this.registerationMS,
  });

  factory UserModel.fromMap(final Map map, {String? uid}) {
    return UserModel(
      uid: uid ?? map["uid"] ?? "uid-not-assigned",
      displayName: map["displayName"] ?? "",
      photoURL: map["photoURL"] ?? Str.dummyProfilePhotoUrl,
      email: map["email"],
      registerationMS: (map["registerationTime"] is Timestamp
                  ? (map["registerationTime"] as Timestamp).toDate()
                  : map["registerationTime"] as DateTime)
              .millisecondsSinceEpoch -
          DateTime(2022).millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "displayName": displayName,
      "photoURL": photoURL,
      "email": email,
      "registerationTime": DateTime.fromMillisecondsSinceEpoch(
        DateTime(2022).millisecondsSinceEpoch + registerationMS,
      ),
    };
  }

  @override
  String toString() => "$displayName $email";

  DateTime get registerationDateTime {
    return DateTime.fromMillisecondsSinceEpoch(
      DateTime(2022).millisecondsSinceEpoch + registerationMS,
    );
  }
}
