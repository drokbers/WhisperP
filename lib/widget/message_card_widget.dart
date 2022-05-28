import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageCardWidget extends StatefulWidget {
  const MessageCardWidget({
    Key? key,
    required this.lastSeen,
    required this.messageTopic,
    required this.unReaded,
    required this.kId,
    required this.messages,
  }) : super(key: key);

  final String kId;
  final String lastSeen;
  final DocumentSnapshot messageTopic;
  final int unReaded;
  final List<DocumentSnapshot> messages;

  @override
  State<MessageCardWidget> createState() => _MessageCardWidgetState();
}

class _MessageCardWidgetState extends State<MessageCardWidget> {
  bool read = false;
  final User? _user = FirebaseAuth.instance.currentUser;
  Map sender = {};
  bool _done = false;
  int oSayisi = 0;

  getUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.kId)
        .get()
        .then(
          (value) => sender = value.data()!,
        );

    if (!_done) setState(() {});
  }

  unreadNumber() async {
    for (var element in widget.messages) {
      if (!(element.data() as Map<String, dynamic>)['read']) {
        oSayisi = oSayisi + 1;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    unreadNumber();
    getUser();
    super.initState();
  }

  @override
  void dispose() {
    _done = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: (widget.messageTopic.data()
                      as Map<String, dynamic>)['receiver_id'] ==
                  sender["sender_id"]
              ? (widget.messageTopic.data() as Map<String, dynamic>)['read']
                  ? Colors.white
                  : Colors.blue
              : Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _user != null
                ? Container(
                    margin: const EdgeInsets.only(right: 10.0),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: (widget.messageTopic.data()
                                  as Map<String, dynamic>)['read']
                              ? Colors.purple
                              : Colors.white,
                          width: 2),
                      borderRadius: BorderRadius.circular(50.0),
                      image: DecorationImage(
                        image: NetworkImage(
                          sender["sender_image"] ??
                              "https://firebasestorage.googleapis.com/v0/b/senv2app.appspot.com/o/gerekliler%2Fprofile_avatar.png?alt=media&token=802d7323-9612-4061-8b78-bf5a838d31bf",
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(right: 10.0),
                    height: 50,
                    width: 50,
                    child: const CircularProgressIndicator(),
                  ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        sender["sender_name"] ?? "unknown",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11.0,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        width: 4.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      Text(
                        widget.lastSeen,
                        style: TextStyle(
                          color: (widget.messageTopic.data()
                                      as Map<String, dynamic>)['receiver'] ==
                                  sender["uid"]
                              ? (widget.messageTopic.data()
                                      as Map<String, dynamic>)['read']
                                  ? Colors.black
                                  : Colors.black
                              : Colors.black,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    (widget.messageTopic.data()
                        as Map<String, dynamic>)['message'],
                    style: TextStyle(
                      fontSize: 15,
                      color: (widget.messageTopic.data()
                                  as Map<String, dynamic>)['receiver_id'] ==
                              sender["sender_id"]
                          ? (widget.messageTopic.data()
                                  as Map<String, dynamic>)['read']
                              ? Colors.black
                              : Colors.white
                          : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if ((widget.messageTopic.data()
                        as Map<String, dynamic>)['receiver_id'] ==
                    sender["sender_id"] &&
                !(widget.messageTopic.data() as Map<String, dynamic>)['read'])
              Container(
                width: 30.0,
                height: 30.0,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Center(
                  child: Text(
                    "$oSayisi",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
