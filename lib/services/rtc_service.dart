import 'package:flutter_webrtc/flutter_webrtc.dart';

class RTCService {
  const RTCService();

  static const instance = RTCService();

  static final rtc = WebRTC();

  Future<void> create() async {
    // final peerConnection = await createPeerConnection();
  }
}
