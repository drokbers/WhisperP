import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whisperp/models/user_model.dart';

import '../consts/index.dart';

class CacheUsersService {
  static Future<void> getAndSaveUsers() async {
    final box = Hive.box<UserModel>(BoxNames.users);

    DateTime lastUserRegisterationTime = DateTime(2022, 1, 1);

    if (box.isNotEmpty) {
      final regTimes = box.values
          .map((e) => e.registerationTime.millisecondsSinceEpoch)
          .toList()
        ..sort();

      lastUserRegisterationTime =
          DateTime.fromMillisecondsSinceEpoch(regTimes.first);
    }

    debugPrint("lastUserRegisterationTime: $lastUserRegisterationTime");
    debugPrint("box values length: ${box.values.length}");

    final usersQuerySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('registerationTime', descending: true)
        .startAfter([Timestamp.fromDate(lastUserRegisterationTime)]).get();

    if (usersQuerySnapshot.docs.isNotEmpty) {
      debugPrint("usersQuerySnapshot: ${usersQuerySnapshot.docs.length}");

      for (final doc in usersQuerySnapshot.docs) {
        final user = UserModel.fromMap(doc.data(), uid: doc.id);

        await box.put(user.uid, user);
      }
    }
  }
}
