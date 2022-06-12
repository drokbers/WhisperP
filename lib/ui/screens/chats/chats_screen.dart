import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whisperp/consts/index.dart';
import 'package:whisperp/ui/constants.dart';

import '../../../models/chat.dart';
import '../../../models/user_model.dart';
import 'components/chat_card.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("uid: ${FirebaseAuth.instance.currentUser?.uid}");

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final messageColRef = FirebaseFirestore.instance.collection('messages');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            messageColRef.where('participants', arrayContains: uid).snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;

            debugPrint("docs.length: ${docs.length}");

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final chatDoc = docs[index].data() as Map<String, dynamic>;

                final partId = (chatDoc['participants'] as List)
                    .where((e) => e != uid)
                    .toList()
                    .first;

                return FutureBuilder<Chat>(
                  future: Future.microtask(() async {
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(partId)
                        .get();

                    final messageDocs = await messageColRef
                        .doc(docs[index].id)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .get();

                    String lastMessage = "";
                    String time = "";

                    if (messageDocs.docs.isNotEmpty) {
                      final messageDoc = messageDocs.docs.first;
                      lastMessage = messageDoc.data()['messageType'] != 'text'
                          ? 'attachment'
                          : messageDoc.data()['text'];

                      time = "${messageDoc.data()['timestamp'].toDate()}";
                    }

                    return Chat(
                      name: userDoc.data()!['displayName'],
                      lastMessage: lastMessage,
                      image: userDoc.data()!['photoURL'],
                      time: time,
                      isActive: false,
                    );
                  }),
                  builder: (_, fsnapshot) {
                    if (fsnapshot.hasData) {
                      return ChatCard(
                        chat: fsnapshot.data!,
                        press: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.messagesScreen,
                            arguments:
                                Hive.box<UserModel>(BoxNames.users).get(partId),
                          );
                        },
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.searchScreen);
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.person_add_alt_1,
          color: Colors.white,
        ),
      ),
    );
  }
}
