import 'dart:io';
import 'dart:typed_data';

class UdpSenderService {
  final String targetIp;
  final int targetPort;
  RawDatagramSocket? _socket;

  UdpSenderService({required this.targetIp, required this.targetPort});

  Future<void> init() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  }

  void send(Uint8List data) {
    _socket?.send(data, InternetAddress(targetIp), targetPort);
  }

  void dispose() {
    _socket?.close();
  }
}
