import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whisperp/ui/chat_page.dart';
import 'package:whisperp/widget/message_card_widget.dart';

import '../model/message_model.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool done = false;
  final StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();
  List<DocumentSnapshot> a = [];
  MessageModel? lastMessage;
  bool process = false;
  bool isMessage = false;

  getMessages() async {
    _controller.add([]);
    a = [];
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('messages')
        .where('relations', arrayContains: user!.uid)
        .orderBy('last_message', descending: true)
        .get();

    if (qs.docs.isNotEmpty) {
      for (DocumentSnapshot ds in qs.docs) {
        if (ds.exists) {
          a.add(ds);
        }
      }
    }
    await _isMessage();
    if (!_controller.isClosed) _controller.add(a);
  }

  _isMessage() async {
    if (a.isNotEmpty) {
      for (DocumentSnapshot ds in a) {
        if ((ds.data() as Map<String, dynamic>)[user!.uid] != null) {
          if ((ds.data() as Map<String, dynamic>)['last_message'] != null) {
            if ((ds.data() as Map<String, dynamic>)['last_message']
                .toDate()
                .isAfter(
                    (ds.data() as Map<String, dynamic>)[user!.uid].toDate())) {
              isMessage = true;
            } else {}
          }
        } else {
          isMessage = true;
        }
      }
    } else {
      isMessage = true;
    }
    if (!done) setState(() {});
  }

  Future delete(String dId) async {
    setState(() {
      process = true;
    });

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(dId)
        .get()
        .then((value) {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(dId)
          .collection('messages')
          .where('receiver_id', isEqualTo: user!.uid)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('messages')
              .doc(dId)
              .update({'unread_number': 0});
        }
        for (DocumentSnapshot ds in value.docs) {
          FirebaseFirestore.instance
              .collection('messages')
              .doc(dId)
              .collection('messages')
              .doc(ds.id)
              .update({'read': true});
        }
      });

      FirebaseFirestore.instance
          .collection('messages')
          .doc(dId)
          .update({user!.uid: FieldValue.serverTimestamp()}).then((value) {
        Fluttertoast.showToast(msg: 'You deleted the ...');
        process = false;

        getMessages();
      });
    });
  }

  void deleteAlert(DocumentSnapshot id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Attention!!!',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          content: const Text("Are you sure to delete the chat ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                delete(id.id);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  static String findTimeDifference(DateTime dt) {
    String sure;
    Duration duration = DateTime.now().difference(dt);
    if (duration.inDays < 1) {
      if (duration.inHours < 1) {
        if (duration.inMinutes < 1) {
          sure = "${duration.inSeconds} Sn";
        } else {
          sure = "${duration.inMinutes} Dk";
        }
      } else {
        sure = "${duration.inHours} Sa";
      }
    } else if (duration.inDays < 7) {
      sure = "${duration.inDays} Gün";
    } else if (duration.inDays < 30) {
      sure = "${(duration.inDays / 7).floor()} Hafta";
    } else if (duration.inDays < 365) {
      sure = "${(duration.inDays / 30).floor()} Ay";
    } else {
      sure = "${(duration.inDays / 365).floor()} Yıl";
    }
    return sure;
  }

  Future read(String dId) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(dId)
        .collection('messages')
        .where('receiver_id', isEqualTo: user!.uid)
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(dId)
            .collection('messages')
            .doc(ds.id)
            .update({'read': true});
      }
    });
  }

  getUsers() async {
    await FirebaseFirestore.instance.collection("users").get();
  }

  @override
  void initState() {
    getMessages();
    getUsers();

    super.initState();
  }

  @override
  void dispose() {
    done = true;
    _controller.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(actions: [
        IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => const ChatPage(
                        karsiId: "GXTQEKCoahYgBEZEo25H7SKoWZa2")));
          },
        )
      ]),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _controller.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: LinearProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            if (snapshot.data!.length < 1) {
              return const Center(
                child: Text("There aren't any messages yet ..."),
              );
            } else {
              return process == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          if (!isMessage)
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 2 -
                                      100),
                              child: const Center(
                                child:
                                    Text("There aren't any messages yet ..."),
                              ),
                            ),
                          for (DocumentSnapshot ds in snapshot.data!)
                            if ((ds.data()
                                        as Map<String, dynamic>)[user!.uid] !=
                                    null
                                ? (ds.data()
                                        as Map<String, dynamic>)['last_message']
                                    .toDate()
                                    .isAfter((ds.data()
                                            as Map<String, dynamic>)[user!.uid]
                                        .toDate())
                                : (ds.data()
                                        as Map<String, dynamic>)[user!.uid] ==
                                    null)
                              FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('messages')
                                      .doc(ds.id)
                                      .collection('messages')
                                      //   .where('read', isEqualTo: false)
                                      //   .where('receiver_id', isEqualTo: Fonksiyon.user.uid)
                                      .orderBy('timestamp', descending: true)
                                      .get(),
                                  builder: (context, snapshotf) {
                                    if (snapshotf.data == null) {
                                      return const IntrinsicHeight(
                                        child: Center(),
                                      );
                                    }
                                    if (snapshotf.data != null &&
                                        snapshotf.data!.docs.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(50.0),
                                        child: Center(
                                          child: Text(
                                              "There aren't any messages!!!"),
                                        ),
                                      );
                                    }
                                    if (snapshotf.connectionState ==
                                        ConnectionState.active) {
                                      return const IntrinsicHeight(
                                          child: CircularProgressIndicator());
                                    }

                                    if (snapshotf.hasData) {
                                      if (snapshotf.data!.docs.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.all(50.0),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      }
                                      DocumentSnapshot lastDoc =
                                          snapshotf.data!.docs.first;
                                      DateTime time2 = (lastDoc.data() as Map<
                                                  String, dynamic>)['timestamp']
                                              .toDate() ??
                                          DateTime.now();

                                      return IntrinsicHeight(
                                        child: InkWell(
                                          onLongPress: () {
                                            deleteAlert(ds);
                                          },
                                          onTap: () {
                                            // //  _read(ds.documentID);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (c) => ChatPage(
                                                  karsiId: (lastDoc.data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'sender_id'] ==
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid
                                                      ? (lastDoc.data()
                                                              as Map<String, dynamic>)[
                                                          'receiver_id']
                                                      : (lastDoc.data() as Map<
                                                          String,
                                                          dynamic>)['sender_id'],
                                                  mesajId: ds.id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: MessageCardWidget(
                                            kId: (lastDoc.data() as Map<String,
                                                            dynamic>)[
                                                        'sender_id'] ==
                                                    user!.uid
                                                ? (lastDoc.data() as Map<String,
                                                    dynamic>)['receiver_id']
                                                : (lastDoc.data() as Map<String,
                                                    dynamic>)['sender_id'],
                                            messageTopic: lastDoc,
                                            lastSeen:
                                                "${findTimeDifference(time2)} Ago",
                                            messages: snapshotf.data!.docs,
                                            unReaded:
                                                snapshotf.data!.docs.length,
                                          ),
                                        ),
                                      );
                                    }

                                    return const IntrinsicHeight(
                                        child: Center());
                                  }),
                        ],
                      ),
                    );
            }
          }
          return const Center();
        },
      ),
    );
  }
}
