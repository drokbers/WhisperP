class RtcOptions {
  static final configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
      {"url": "stun:stun1.l.google.com:19302"},
      {"url": "stun:stun2.l.google.com:19302"},
      {"url": "stun:stun3.l.google.com:19302"},
      {"url": "stun:stun4.l.google.com:19302"},
    ],
  };

  static final loopbackConstraints = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": true},
    ],
  };

  static final offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": false,
    },
    "optional": [],
  };

  static final mediaConstraints = {
    'audio': true,
    'video': false,
  };

  static final offerMessagingSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": false,
      "OfferToReceiveVideo": false,
    },
    "optional": [],
  };

  static final messagingMediaConstraints = {
    'audio': false,
    'video': false,
  };
}
