import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../utils/rtc_options.dart';

class RTCProvider {
  static RTCProvider? _instance;

  factory RTCProvider() {
    _instance ??= RTCProvider._createInstance();

    return _instance!;
  }

  RTCProvider._createInstance();

  final _localRenderer = RTCVideoRenderer(),
      _remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _locaDataChannel, _remoteDataChannel;

  MediaStream? _localMediaStream, _remoteMediaStream;

  final _localTracks = <MediaStreamTrack>[];

  StreamSubscription<DocumentSnapshot>? _waitForAnswerStrem, _waitForSdp;
  StreamSubscription<QuerySnapshot>? _waitCandidates;

  DocumentReference? _myDocRef, _remotePersonDocRef;

  final _candidates = <String>[];
  String _sessionID = "";

  String get sessionID => _sessionID;

  final _myUID = FirebaseAuth.instance.currentUser!.uid;

  String? _remotePerson;
  bool _muted = false;
  DateTime? _now;

  RTCDataChannel? get localDataChannel => _locaDataChannel;
  RTCDataChannel? get remoteDataChannel => _remoteDataChannel;

  RTCPeerConnection? get peerConnection => _peerConnection;

  bool get muted => _muted;

  Future<void> _createLocalStream() async {
    await _initRenderers();

    _localMediaStream =
        await navigator.mediaDevices.getUserMedia(RtcOptions.mediaConstraints);

    if (_localMediaStream != null) {
      _localTracks.clear();

      _localTracks.addAll(_localMediaStream!.getAudioTracks());

      _localRenderer.srcObject = _localMediaStream;

      if (_peerConnection != null) {
        await _peerConnection!.addStream(_localMediaStream!);
      }
    }
  }

  Future<void> _createLocalDataChannel() async {
    final dataChannelInit = RTCDataChannelInit();

    dataChannelInit.id = 1;
    dataChannelInit.ordered = true;
    dataChannelInit.maxRetransmitTime = -1;
    dataChannelInit.maxRetransmits = -1;
    dataChannelInit.protocol = "sctp";
    dataChannelInit.negotiated = false;
    if (_peerConnection != null) {
      _locaDataChannel = await _peerConnection!
          .createDataChannel('dataChannel', dataChannelInit);
    }
  }

  Future<void> _createPC() async {
    if (_peerConnection != null) return;

    _peerConnection = await createPeerConnection(
      RtcOptions.configuration,
      RtcOptions.loopbackConstraints,
    );

    _peerConnection!.onAddStream = _onAddStream;
    _peerConnection!.onRemoveStream = _onRemoveStream;
    _peerConnection!.onDataChannel = _onDataChannel;
    _peerConnection!.onIceCandidate = _onIceCandidate;
    _peerConnection!.onIceGatheringState = _onIceGatheringState;
    _peerConnection!.onIceConnectionState = _onIceConnectionState;
    _peerConnection!.onRenegotiationNeeded = _onRenegotiationNeeded;
    _peerConnection!.onSignalingState = _onSignalingState;

    await _createLocalStream();
    await _createLocalDataChannel();
  }

  Future<void> mute() async {
    if (_muted) {
      for (MediaStreamTrack mst in _localTracks) {
        await _localMediaStream!.removeTrack(mst);
      }
      _muted = true;
    } else {
      for (MediaStreamTrack mst in _localTracks) {
        await _localMediaStream!.addTrack(mst);
      }
      _muted = false;
    }
  }

  Future<void> createOffer(String to) async {
    _remotePerson = to;
    await _createPC();
    if (_sessionID.isEmpty) _sessionID = getRandomString(20);

    if (_peerConnection != null) {
      try {
        final description =
            await _peerConnection!.createOffer(RtcOptions.offerSdpConstraints);

        _peerConnection!.setLocalDescription(description);

        _myDocRef = FirebaseFirestore.instance.collection('users').doc(_myUID);

        _remotePersonDocRef =
            FirebaseFirestore.instance.collection('users').doc(_remotePerson);

        await _myDocRef!.collection('sessions').doc(_sessionID).set({
          ...description.toMap(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _remotePersonDocRef!.update({
          'calling': _myUID,
          'session': _sessionID,
          'callingLastUpdate': DateTime.now(),
        });

        _now = DateTime.now()..add(const Duration(seconds: 1));
        // bool timeOut = false;

        _waitForAnswerStrem = _remotePersonDocRef!.snapshots().listen((ds1) {
          final ds1Map = ds1.data()! as Map;
          final callingLastUpdate = ds1Map['callingLastUpdate'].toDate();

          if (ds1Map['calling'] == _myUID && callingLastUpdate.isAfter(_now)) {
            _waitForAnswerStrem!.cancel();

            final dr2 =
                _remotePersonDocRef!.collection('sessions').doc(_sessionID);

            _waitForSdp = dr2.snapshots().listen((ds2) {
              if (ds2.exists) {
                final ds2Map = ds2.data()!;

                final rDescription =
                    RTCSessionDescription(ds2Map['sdp'], ds2Map['type']);

                _peerConnection!
                    .setRemoteDescription(rDescription)
                    .whenComplete(() {
                  _waitForSdp!.cancel();

                  _waitCandidates = dr2
                      .collection('candidates')
                      .snapshots()
                      .listen((qsEvent) {
                    _addRemoteCandidatesFromQS(qsEvent);
                  });
                });
              }
            });
          }
          /*  else if (ds1.data()['calling'] == "") {
          _waitForAnswerStrem.cancel();
          hungUp();
        } else if (!timeOut) {
          Future.delayed(Duration(milliseconds: 1500)).whenComplete(() {
            timeOut = true;
            _waitForAnswerStrem.cancel();
            hungUp();
          });
        } */
        });
      } catch (e) {
        debugPrint("error occured when trying to createOffer $e");
      }
    }
  }

  Future<void> _addRemoteCandidatesFromQS(
      QuerySnapshot<Map<String, dynamic>> qs) async {
    for (DocumentSnapshot<Map> ds in qs.docs) {
      if (!_candidates.contains(ds.data()!['candidate'])) {
        try {
          await _peerConnection!.addCandidate(
            RTCIceCandidate(
              ds.data()!['candidate'],
              ds.data()!['sdpMid'],
              ds.data()!['sdpMLineIndex'],
            ),
          );

          _candidates.add(ds.data()!['candidate']);
        } catch (e) {
          debugPrint("error adding candidate $e");
        }
      }
    }
  }

  Future<void> createAnswer(String session, String to) async {
    if (_sessionID.isEmpty) _sessionID = session;
    _remotePerson = to;

    await _createPC();

    _myDocRef = FirebaseFirestore.instance.collection('users').doc(_myUID);
    _remotePersonDocRef =
        FirebaseFirestore.instance.collection('users').doc(_remotePerson);

    final dr2 = _remotePersonDocRef!.collection('sessions').doc(_sessionID);
    final ds = await dr2.get();

    try {
      final rDescription =
          RTCSessionDescription(ds.data()!['sdp'], ds.data()!['type']);
      _peerConnection!.setRemoteDescription(rDescription);
    } catch (e) {
      debugPrint("error adding answerDescription createAnswer $e");
    }

    try {
      final lDescription =
          await _peerConnection!.createAnswer(RtcOptions.offerSdpConstraints);
      _peerConnection!.setLocalDescription(lDescription);

      await _myDocRef!
          .collection('sessions')
          .doc(_sessionID)
          .set(lDescription.toMap());

      debugPrint(
          "_myDocRef.collection('sessions').doc(_sessionID).set(lDescription.toMap());");
    } catch (e) {
      debugPrint("error adding answerDescription createAnswer $e");
    }

    final qs = await dr2.collection('candidates').get();
    await _addRemoteCandidatesFromQS(qs);

    _waitCandidates =
        dr2.collection('candidates').snapshots().listen((qsEvent) {
      _addRemoteCandidatesFromQS(qsEvent);
    });

    _now = DateTime.now()..add(const Duration(seconds: 1));

    await _remotePersonDocRef!.update({
      'calling': _myUID,
      'session': _sessionID,
      'callingLastUpdate': DateTime.now(),
    });

    final myDoc = await _myDocRef!.get();
    final remoteTime = (myDoc.data()! as Map)['callingLastUpdate'].toDate();

    await _myDocRef!.update(
      {
        'callingLastUpdate': remoteTime.isBefore(_now)
            ? _now
            : remoteTime.add(const Duration(seconds: 10))
      },
    );
  }

  Future<void> hungUp(String session, String to) async {
    if (_waitForAnswerStrem != null) {
      await _waitForAnswerStrem!.cancel();
      _waitForAnswerStrem = null;
    }

    if (_waitForSdp != null) {
      await _waitForSdp!.cancel();
      _waitForSdp = null;
    }

    if (_waitCandidates != null) {
      await _waitCandidates!.cancel();
      _waitCandidates = null;
    }

    if (_peerConnection != null && _localMediaStream != null) {
      try {
        _peerConnection!.removeStream(_localMediaStream!);
        _localMediaStream!.dispose();
        _localMediaStream = null;

        await _peerConnection!.close();
        _peerConnection = null;

        if (_locaDataChannel != null) {
          await _locaDataChannel!.close();
          _locaDataChannel = null;
        }

        if (_remoteDataChannel != null) {
          await _remoteDataChannel!.close();
          _remoteDataChannel = null;
        }
      } on PlatformException catch (pe) {
        debugPrint("$pe");
      } catch (e) {
        debugPrint("$e");
      }
    }

    if (_remoteMediaStream != null) {
      try {
        _remoteMediaStream!.dispose();
        _remoteMediaStream = null;
      } on PlatformException catch (pe) {
        debugPrint("$pe");
      } catch (e) {
        debugPrint("$e");
      }
    }

    try {
      _localRenderer.srcObject = null;
      if (!Platform.isAndroid) {
        await _localRenderer.dispose();
      }
      _remoteRenderer.srcObject = null;
      if (!Platform.isAndroid) {
        await _remoteRenderer.dispose();
      }
    } on PlatformException catch (pe) {
      debugPrint("$pe");
    } catch (e) {
      debugPrint("$e");
    }

    _sessionID = "";
  }

  Future _clearFirebase(DocumentReference docRef) async {
    final dr = docRef.collection('sessions').doc(_sessionID);
    final ds = await dr.get();

    if (ds.exists) {
      await dr.update({'started': _now, 'ended': FieldValue.serverTimestamp()});
    }
    await docRef.update({
      'calling': "",
      'session': "",
      'callingLastUpdate': FieldValue.serverTimestamp(),
    });
  }

  _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _onAddStream(MediaStream stream) {
    _remoteMediaStream = stream;
    _remoteRenderer.srcObject = _remoteMediaStream;
  }

  _onRemoveStream(MediaStream stream) {
    _remoteMediaStream = null;
    _remoteRenderer.srcObject = null;
  }

  _onSignalingState(RTCSignalingState signalingState) {
    switch (signalingState) {
      case RTCSignalingState.RTCSignalingStateClosed:
        if (_myDocRef != null) {
          _clearFirebase(_myDocRef!).whenComplete(() => _myDocRef = null);
        }

        if (_remotePersonDocRef != null) {
          _clearFirebase(_remotePersonDocRef!)
              .whenComplete(() => _remotePersonDocRef = null);
        }

        debugPrint("switch: RTCSignalingStateClosed");
        break;

      case RTCSignalingState.RTCSignalingStateHaveLocalOffer:
        debugPrint("switch: RTCSignalingStateHaveLocalOffer");
        break;

      case RTCSignalingState.RTCSignalingStateHaveLocalPrAnswer:
        debugPrint("switch: RTCSignalingStateHaveLocalPrAnswer");
        break;

      case RTCSignalingState.RTCSignalingStateHaveRemoteOffer:
        debugPrint("switch: RTCSignalingStateHaveRemoteOffer");
        break;

      case RTCSignalingState.RTCSignalingStateHaveRemotePrAnswer:
        debugPrint("switch: RTCSignalingStateHaveRemotePrAnswer");
        break;

      case RTCSignalingState.RTCSignalingStateStable:
        _myDocRef!.update({'connnected': true});
        debugPrint("switch: RTCSignalingStateStable");
        break;

      default:
        debugPrint("switch default: onSignalingState: $signalingState");
        break;
    }
  }

  _onRenegotiationNeeded() => debugPrint("onRenegotiationNeeded");

  _onIceGatheringState(RTCIceGatheringState iceGatheringState) {
    switch (iceGatheringState) {
      case RTCIceGatheringState.RTCIceGatheringStateComplete:
        debugPrint("switch: iceGatheringState RTCIceGatheringStateComplete");
        break;

      case RTCIceGatheringState.RTCIceGatheringStateGathering:
        debugPrint("switch: iceGatheringState RTCIceGatheringStateGathering");
        break;

      case RTCIceGatheringState.RTCIceGatheringStateNew:
        debugPrint("switch: iceGatheringState RTCIceGatheringStateNew");
        break;

      default:
        debugPrint("switch default onIceGatheringState: $iceGatheringState");
        break;
    }
  }

  _onIceConnectionState(RTCIceConnectionState iceConnectionState) {
    switch (iceConnectionState) {
      case RTCIceConnectionState.RTCIceConnectionStateChecking:
        debugPrint(
            "switch onIceConnectionState: RTCIceConnectionStateChecking");
        break;

      case RTCIceConnectionState.RTCIceConnectionStateClosed:
        debugPrint("switch onIceConnectionState: RTCIceConnectionStateClosed");
        break;

      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        debugPrint(
            "switch onIceConnectionState: RTCIceConnectionStateCompleted");
        break;

      case RTCIceConnectionState.RTCIceConnectionStateConnected:
        //        if (_myDocRef != null || _remotePersonDocRef != null) hungUp();

        debugPrint(
            "switch onIceConnectionState: RTCIceConnectionStateConnected");
        break;

      case RTCIceConnectionState.RTCIceConnectionStateCount:
        debugPrint("switch onIceConnectionState: RTCIceConnectionStateCount");
        break;

      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        debugPrint(
            "switch onIceConnectionState: RTCIceConnectionStateDisconnected");
        break;

      case RTCIceConnectionState.RTCIceConnectionStateFailed:
        //        if (_myDocRef != null || _remotePersonDocRef != null) hungUp();

        debugPrint("switch onIceConnectionState: RTCIceConnectionStateFailed");
        break;

      case RTCIceConnectionState.RTCIceConnectionStateNew:
        debugPrint("switch onIceConnectionState: RTCIceConnectionStateNew");
        break;

      default:
        debugPrint("switch default onIceConnectionState: $iceConnectionState");
        break;
    }
  }

  _onDataChannel(RTCDataChannel dataChannel) {
    _remoteDataChannel = dataChannel;
  }

  _onIceCandidate(RTCIceCandidate iceCandidate) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_myUID)
        .collection('sessions')
        .doc(_sessionID)
        .collection('candidates')
        .add({
      ...iceCandidate.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  final _rnd = Random();

  String getRandomString(int length) {
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
