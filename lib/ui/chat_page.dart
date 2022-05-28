import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whisperp/model/user_model.dart';

import '../model/message_model.dart';
import '../widget/button_back.dart';
import '../widget/edit_message_widget.dart';

class ChatPage extends StatefulWidget {
  final String karsiId;
  final String? mesajId;

  const ChatPage({Key? key, required this.karsiId, this.mesajId})
      : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final StreamController<List<MessageModel>> _controller =
      StreamController<List<MessageModel>>();
  UserModel? otherUser;
  bool _endScroll = true;
  String? _id;
  bool _done = false;
  DateTime? deleteTime;

  void _scrollToBottom() {
    try {
      _scrollController.animateTo(0.0,
          duration:
              Duration(milliseconds: (_scrollController.offset / 5).floor()),
          curve: Curves.easeOut);
    } catch (e) {
      _findId();
    }
  }

  Future<UserModel> getOther(String id) async {
    DocumentSnapshot<Map> ds =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    debugPrint(ds.data().toString());
    return UserModel.fromMap({"uid": ds.id, ...ds.data()!});
  }

  Future _read(String gDId) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(_id)
        .update({'unreadNumber': 0});

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(_id)
        .collection('messages')
        .doc(gDId)
        .update({'read': true});
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

  void _deleteAlert(DocumentSnapshot id) {
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
          content: const Text("Are you sure to delete the message ? "),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _delete(id.id);
                Navigator.pop(context);
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

  Future _delete(String dId) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(widget.mesajId)
        .collection('messages')
        .doc(dId)
        .update({'message': 'Message deleted ...'}).then((value) {
      _findId();
    });
  }

  _findId() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection('messages')
        .doc('${FirebaseAuth.instance.currentUser!.uid}::${widget.karsiId}')
        .get();

    if (ds.exists) {
      _id = ds.id;
    } else {
      DocumentSnapshot ds2 = await FirebaseFirestore.instance
          .collection('messages')
          .doc('${widget.karsiId}::${FirebaseAuth.instance.currentUser!.uid}')
          .get();
      if (ds2.exists) {
        _id = '${widget.karsiId}::${FirebaseAuth.instance.currentUser!.uid}';
      }
    }
    await _deletedMessageModel();

    setState(() {});
  }

  _deletedMessageModel() async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(_id)
        .get()
        .then((value) {
      if (value.exists) {
        if ((value.data() as Map<String, dynamic>)[
                FirebaseAuth.instance.currentUser!.uid] !=
            null) {
          deleteTime = (value.data() as Map<String, dynamic>)[
                  FirebaseAuth.instance.currentUser!.uid]
              .toDate();
        }
      }
    });
  }

  @override
  void initState() {
    _findId();
    //_mesajCek();

    if (widget.karsiId.isNotEmpty) {
      getOther(widget.karsiId).then((k) {
        otherUser = k;
        if (!_done) setState(() {});
      });
    }

    _scrollController.addListener(() {
      if (_scrollController.offset <
          _scrollController.position.viewportDimension) {
        if (!_endScroll) setState(() => _endScroll = true);
      } else {
        if (_endScroll) setState(() => _endScroll = false);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _done = true;
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: otherUser == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ChatTopCard(otherUser: otherUser),
                  if (_id == null)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Hiç MessageModel Yok',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  if (_id != null)
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .doc(_id)
                            .collection('messages')
                            .limit(220)
                            .where('timestamp', isGreaterThan: deleteTime)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text(
                                'Hiç MessageModel Yok',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          } else {
                            if (snapshot.data!.docs.length < 1) {
                              return const Center(
                                child: Text(
                                  'Hiç MessageModel Yok',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.data.docs.length > 0) {
                              return ListView.builder(
                                reverse: true,
                                controller: _scrollController,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (c, i) {
                                  MessageModel? messageModel;
                                  bool benMi = false;
                                  DateTime? time;

                                  DocumentSnapshot ds = snapshot.data.docs[i];
                                  List ilgi = (ds.data()
                                      as Map<String, dynamic>)['relations'];
                                  int s = 0;

                                  if (ilgi.contains(otherUser!.uid)) {
                                    messageModel = MessageModel.fromJson(
                                        ds.data() as Map<String, dynamic>);

                                    benMi = messageModel.senderId ==
                                        FirebaseAuth.instance.currentUser!.uid;

                                    time = messageModel.timestamp;
                                  } else {
                                    s = s + 1;
                                  }

                                  if (!benMi && !messageModel!.read) {
                                    _read(ds.id);
                                  }

                                  if (s > 0) return Container();

                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onLongPress: () {
                                        if (benMi) _deleteAlert(ds);
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          if (messageModel!.message !=
                                              'Message deleted ...')
                                            if (!benMi)
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(10.0),
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                  //  border: Border.all(color: Colors.turuncu57, width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      messageModel.senderImage,
                                                    ),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: benMi
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  margin: EdgeInsets.only(
                                                      right: benMi ? 3 : 12.0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: benMi
                                                            ? Colors.purple
                                                            : messageModel
                                                                        .message ==
                                                                    'Message deleted ...'
                                                                ? Colors.white
                                                                : Colors.orange,
                                                        width: 1),
                                                    color: messageModel
                                                                .message ==
                                                            'Message deleted ...'
                                                        ? Colors.grey
                                                            .withOpacity(0.8)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Text(
                                                    messageModel.message,
                                                    style: TextStyle(
                                                      color: benMi
                                                          ? Colors.purple
                                                          : messageModel
                                                                      .message ==
                                                                  'Message deleted ...'
                                                              ? Colors.white
                                                              : Colors.orange,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12, top: 5),
                                                  child: Text(
                                                    "${findTimeDifference(time!)} Önce",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          if (messageModel.message !=
                                              'Message deleted ...')
                                            if (benMi)
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(10.0),
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                  //   border: Border.all(color: Colors.turuncu57, width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        messageModel
                                                            .senderImage),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  EditMessageWidget(
                    mesajId: widget.mesajId,
                    dm: true,
                    f: _scrollToBottom,
                    karsiId: otherUser!.uid,
                  ),
                ],
              ),
            ),
    );
  }
}

class ChatTopCard extends StatelessWidget {
  const ChatTopCard({
    Key? key,
    required this.otherUser,
  }) : super(key: key);

  final UserModel? otherUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: SizedBox(
        height: 40,
        width: double.maxFinite,
        child: Row(
          children: [
            const SizedBox(width: 8),
            const ButtonBack(
              backgroundColor: Colors.orange,
              borderColor: Colors.orange,
              height: 30,
              iconColor: Colors.white,
              iconSize: 28,
              width: 30,
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.purple, width: 1),
                    image: DecorationImage(
                      image: NetworkImage(
                        otherUser!.photoURL,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    otherUser!.displayName,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.orange,
              ),
              onPressed: () {
                Fluttertoast.showToast(
                  msg: 'This section not avaliable yet ...',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
