import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:whisperp/models/chat_message.dart';
import 'package:whisperp/models/user_model.dart';
import 'package:whisperp/services/rtc_provider.dart';
import 'package:whisperp/ui/constants.dart';
import 'package:flutter/material.dart';
import 'package:whisperp/ui/screens/messages/components/call_alert.dart';

import 'components/chat_input_field.dart';
import 'components/text_message.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as UserModel;
    final colRef = FirebaseFirestore.instance.collection('messages');
    final controller = ScrollController();
    final rtcProvider = RTCProvider();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const BackButton(),
            CircleAvatar(
              child: ClipOval(
                child: kIsWeb
                    ? Image.network(user.photoURL)
                    : CachedNetworkImage(
                        imageUrl: user.photoURL,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                      ),
              ),
            ),
            const SizedBox(width: kDefaultPadding * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  "Online",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )
          ],
        ),
        actions: [
          StreamBuilder<DocumentSnapshot<Map>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!.data()!;

                final calling = data['calling'] as String?;
                final session = data['session'] as String?;

                if ("$calling".isNotEmpty && "$session".isNotEmpty) {
                  if (data.containsKey('callingLastUpdate')) {
                    final callingLastUpdate =
                        (data['callingLastUpdate'] as Timestamp).toDate();

                    if (callingLastUpdate.isBefore(
                        DateTime.now().subtract(const Duration(seconds: 30)))) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'calling': null,
                        'session': null,
                        'callingLastUpdate': FieldValue.serverTimestamp(),
                      });
                    } else {
                      Future.delayed(const Duration(milliseconds: 300))
                          .whenComplete(() {
                        showDialog(
                          context: context,
                          builder: (_) => CallAlert(
                            calling: calling!,
                            sessionId: session!,
                            rtcProvider: rtcProvider,
                          ),
                        );
                      });
                    }
                  }
                }
              }
              return const SizedBox();
            },
          ),
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {
              rtcProvider.createOffer(user.uid);
            },
          ),
          const SizedBox(width: kDefaultPadding / 2),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
        child: FutureBuilder<String>(
          future: Future.microtask(() async {
            final uid = FirebaseAuth.instance.currentUser?.uid;

            final doc1 = await colRef.doc("${user.uid}::$uid").get();

            if (doc1.exists) return doc1.id;

            final doc2 = await colRef.doc("$uid::${user.uid}").get();

            if (doc2.exists) return doc2.id;

            await colRef.doc("$uid::${user.uid}").set({
              'participants': [uid, user.uid],
              'timestamp': FieldValue.serverTimestamp(),
            });

            // KISS - SOLID - DRY - WET

            return "$uid::${user.uid}";
          }),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final docId = snapshot.data!;
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: colRef
                    .doc(docId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .endBefore([
                  Timestamp.fromDate(DateTime(2022, 1, 1)),
                ]).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;

                    Future.delayed(const Duration(milliseconds: 50))
                        .whenComplete(() {
                      controller.jumpTo(0);
                    });

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: controller,
                            reverse: true,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final message = ChatMessage.fromMap(
                                docs[index].data(),
                              );

                              return TextMessage(message: message);
                            },
                          ),
                        ),
                        ChatInputField(messagesDocId: docId),
                      ],
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
