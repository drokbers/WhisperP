import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/message_model.dart';

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
  State<EditMessageWidget> createState() => _EditMessageWidgetState();
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
      widget.f();

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
        widget.f();

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

          widget.f();

          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5, left: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100.0),
        child: IntrinsicHeight(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    width: double.maxFinite,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12),
                      child: TextField(
                        controller: TextEditingController(text: _mesaj.value),
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
                ),
                ValueListenableBuilder(
                  valueListenable: _mesaj,
                  builder: (c, v, _) {
                    return IconButton(
                      onPressed: _mesaj.value.length > 0 && !_islem
                          ? () async {
                              _islem = true;
                              setState(() {});

                              _mesajGonder(_mesaj.value);
                            }
                          : null,
                      icon: Icon(
                        Icons.send,
                        color: _mesaj.value.length > 0
                            ? Colors.orange
                            : Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
