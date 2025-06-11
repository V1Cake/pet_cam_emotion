import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  WebSocketChannel? _channel;
  final String wsUrl = 'ws://<PC_IP>:8765'; // 替换为PC端IP

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel!.stream.listen((data) {
      final result = jsonDecode(data);
      // 处理关键点数据
      print(result['keypoints']);
    });
  }

  void dispose() {
    _channel?.sink.close();
  }
}
