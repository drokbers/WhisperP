import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:whisperp/models/chat_message.dart';
import 'package:whisperp/models/user_model.dart';
import 'package:whisperp/services/rtc_provider.dart';
import 'package:whisperp/ui/constants.dart';

import 'components/text_message.dart';

class SecureMessagesScreen extends StatelessWidget {
  const SecureMessagesScreen({
    super.key,
    required this.rtcProvider,
    required this.user,
  });

  final RTCProvider rtcProvider;
  final UserModel user;

  Future<void> _listenRemoteDataChannel(Box box) async {
    while (rtcProvider.remoteDataChannel == null) {
      await Future.delayed(const Duration(milliseconds: 200));

      if (rtcProvider.remoteDataChannel != null) {
        rtcProvider.remoteDataChannel!.messageStream.listen((m) {
          final rKey = encrypt.Key.fromUtf8(
            "${FirebaseAuth.instance.currentUser!.uid}${user.uid}"
                .substring(0, 32),
          );

          final rIv = encrypt.IV.fromLength(16);

          final rEncrypter = encrypt.Encrypter(encrypt.AES(rKey));

          final decrypted = rEncrypter.decrypt(
            encrypt.Encrypted(
              Uint8List.fromList(
                (jsonDecode(m.text) as List).cast<int>(),
              ),
            ),
            iv: rIv,
          );

          final message = ChatMessage(
            text: decrypted,
            senderId: user.uid,
            messageType: ChatMessageType.text,
            messageStatus: MessageStatus.notview,
            timestamp: DateTime.now(),
          );

          box.add(message.toMap());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();

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
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: kDefaultPadding / 2),
        ],
      ),
      body: FutureBuilder<Box>(
        future: Future.microtask(() async {
          if (Hive.isBoxOpen(user.uid)) {
            return Hive.box(user.uid);
          } else {
            return await Hive.openBox(user.uid);
          }
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final textEditCtrlr = TextEditingController(text: "");
            _listenRemoteDataChannel(snapshot.data!);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                children: [
                  Expanded(
                    child: HiveListener(
                      box: snapshot.data!,
                      builder: (box) {
                        Future.delayed(const Duration(milliseconds: 50))
                            .whenComplete(() {
                          controller
                              .jumpTo(controller.position.maxScrollExtent);
                        });

                        return ListView.builder(
                          controller: controller,
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            final message = ChatMessage.fromMap(
                              box.values.toList()[index] as Map,
                            );

                            return TextMessage(message: message);
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultPadding,
                      vertical: kDefaultPadding / 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 32,
                          color: const Color(0xFF087949).withOpacity(0.08),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          const Icon(Icons.mic, color: kPrimaryColor),
                          const SizedBox(width: kDefaultPadding),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kDefaultPadding * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: textEditCtrlr,
                                      decoration: const InputDecoration(
                                        hintText: "Type message",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding / 4),
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color!
                                        .withOpacity(0.64),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (textEditCtrlr.text.isNotEmpty) {
                                if (rtcProvider.localDataChannel != null) {
                                  final key = encrypt.Key.fromUtf8(
                                    "${user.uid}${FirebaseAuth.instance.currentUser!.uid}"
                                        .substring(0, 32),
                                  );

                                  final iv = encrypt.IV.fromLength(16);

                                  final encrypter =
                                      encrypt.Encrypter(encrypt.AES(key));

                                  final encrypted = encrypter
                                      .encrypt(textEditCtrlr.text, iv: iv);

                                  rtcProvider.localDataChannel!.send(
                                    RTCDataChannelMessage(
                                      jsonEncode(encrypted.bytes),
                                    ),
                                  );

                                  final message = ChatMessage(
                                    text: textEditCtrlr.text,
                                    senderId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    messageType: ChatMessageType.text,
                                    messageStatus: MessageStatus.notview,
                                    timestamp: DateTime.now(),
                                  );

                                  snapshot.data!.add(message.toMap());
                                }

                                textEditCtrlr.text = "";
                              }
                            },
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
