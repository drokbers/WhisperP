import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whisperp/models/user_model.dart';
import 'package:whisperp/services/rtc_provider.dart';
import 'package:whisperp/ui/screens/messages/secure_messages_screen.dart';

class MessageAlert extends StatelessWidget {
  const MessageAlert({
    super.key,
    required this.calling,
    required this.sessionId,
    required this.rtcProvider,
    required this.user,
  });

  final String calling;
  final String sessionId;

  final UserModel user;

  final RTCProvider rtcProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Message Alert"),
      content: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            FirebaseFirestore.instance.collection('users').doc(calling).get(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final userMap = snapshot.data!.data()!;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "${userMap['displayName']} is inviting you for secure messaging"),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            rtcProvider.hungUp(sessionId, calling);
            Navigator.pop(context);
          },
          child: const Text("Reject"),
        ),
        TextButton(
          onPressed: () {
            rtcProvider.createMessageAnswer(sessionId, calling);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SecureMessagesScreen(rtcProvider: rtcProvider, user: user),
              ),
            );
          },
          child: const Text("Accept"),
        ),
      ],
    );
  }
}
