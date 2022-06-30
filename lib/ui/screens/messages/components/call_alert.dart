import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whisperp/services/rtc_provider.dart';

class CallAlert extends StatelessWidget {
  const CallAlert({
    super.key,
    required this.calling,
    required this.sessionId,
    required this.rtcProvider,
  });

  final String calling;
  final String sessionId;

  final RTCProvider rtcProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Call Alert"),
      content: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            FirebaseFirestore.instance.collection('users').doc(calling).get(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final userMap = snapshot.data!.data()!;

            return Column(
              children: [
                Text("${userMap['displayName']} is calling"),
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
          },
          child: const Text("Reject"),
        ),
        TextButton(
          onPressed: () {
            rtcProvider.createAnswer(sessionId, calling);
          },
          child: const Text("Answer"),
        ),
      ],
    );
  }
}
