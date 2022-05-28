import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/message_model.dart';

class EditMessageWidget extends StatefulWidget {
  final Function f;
  final bool dm;
  final String karsiId;
  final String? mesajId;

  const EditMessageWidget({
    Key? key,
    required this.f,
    required this.dm,
    required this.karsiId,
    this.mesajId,
  }) : super(key: key);
  @override
  _EditMessageWidgetState createState() => _EditMessageWidgetState();
}

class _EditMessageWidgetState extends State<EditMessageWidget> {
  final ValueNotifier _mesaj = ValueNotifier('');
  final String tag = "EditMessageWidget";

  bool _islem = false;
  _mesajGonder(String mesaj) async {
    MessageModel m;

    m = MessageModel.fromJson({
      'message': mesaj,
      'sender_id': FirebaseAuth.instance.currentUser!.uid,
      'sender_image': FirebaseAuth.instance.currentUser!.photoURL,
      'sender_name': FirebaseAuth.instance.currentUser!.displayName,
      'timestamp': Timestamp.now(),
      'receiver_id': widget.karsiId,
      'relations': [
        FirebaseAuth.instance.currentUser!.uid,
        widget.karsiId,
      ]
    });

    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection('messages')
        .doc('${FirebaseAuth.instance.currentUser!.uid}::${widget.karsiId}')
        .get();
    if (ds.exists) {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(ds.id)
          .collection('messages')
          .add(m.toJson());
      FirebaseFirestore.instance.collection('messages').doc(ds.id).update({
        'last_message': Timestamp.now(),
        'unread_number': FieldValue.increment(1),
        'unread_person': widget.karsiId
      });

      _islem = false;
      _mesaj.value = "";
      if (widget.f != null) widget.f();

      setState(() {});
    } else {
      DocumentSnapshot ds2 = await FirebaseFirestore.instance
          .collection('messages')
          .doc('${widget.karsiId}::${FirebaseAuth.instance.currentUser!.uid}')
          .get();

      if (ds2.exists) {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(ds2.id)
            .collection('messages')
            .add(m.toJson());
        FirebaseFirestore.instance.collection('messages').doc(ds2.id).update({
          'last_message': Timestamp.now(),
          'unread_number': FieldValue.increment(1),
          'unread_person': widget.karsiId
        });
        _islem = false;
        _mesaj.value = "";
        if (widget.f != null) widget.f();

        setState(() {});
      } else {
        FirebaseFirestore.instance
            .collection('messages')
            .doc('${FirebaseAuth.instance.currentUser!.uid}::${widget.karsiId}')
            .set({
          'relations': [
            widget.karsiId,
            FirebaseAuth.instance.currentUser!.uid,
          ],
          'last_message': Timestamp.now(),
          'unread_number': 0,
          'unread_person': widget.karsiId
        }).then((value) {
          FirebaseFirestore.instance
              .collection('messages')
              .doc(
                  '${FirebaseAuth.instance.currentUser!.uid}::${widget.karsiId}')
              .collection('messages')
              .add(m.toJson());
          _islem = false;
          _mesaj.value = "";

          if (widget.f != null) widget.f();

          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100.0),
        child: IntrinsicHeight(
          child: Card(
            elevation: 0,
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xffe6e7f7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.image,
                      color: Color(0xff6462e2),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      border: Border.all(
                        width: 0.5,
                        color: Colors.black54,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 12.0, right: 12),
                            child: TextField(
                              controller:
                                  TextEditingController(text: _mesaj.value),
                              expands: true,
                              maxLines: null,
                              minLines: null,
                              onChanged: (m) => _mesaj.value = m,
                              cursorColor: Colors.purple,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'mesaj yaz..',
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _mesaj,
                          builder: (c, v, _) {
                            return Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xffe6e7f7),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                onPressed: _mesaj.value.length > 0 && !_islem
                                    ? () async {
                                        _islem = true;
                                        setState(() {});

                                        _mesajGonder(_mesaj.value);
                                      }
                                    : null,
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.send,
                                  color: _mesaj.value.length > 0
                                      ? Color(0xff6462e2)
                                      : Colors.black87,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}