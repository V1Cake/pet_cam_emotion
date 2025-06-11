import 'package:camera/camera.dart';
import 'dart:async';
import '../utils/frame_queue.dart';
import 'package:vet_motion_cam/services/udp_sender_service.dart';
import '../utils/image_utils.dart';
import 'package:vet_motion_cam/services/websocket_service.dart';

class CameraService {
  CameraController? _controller;
  Timer? _timer;
  final FrameQueue<CameraImage> frameQueue = FrameQueue<CameraImage>(
    maxLength: 10,
  );

  CameraImage? _latestImage;

  final void Function()? onFrameSampled;

  UdpSenderService? udpSender;
  WebSocketService? _webSocketService;

  CameraService({this.onFrameSampled});

  Future<void> initialize() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    _controller?.startImageStream(onImage);
    _startFrameSampling();
    _webSocketService = WebSocketService();
    _webSocketService!.connect();
  }

  Future<void> initializeUdpSender(String ip, int port) async {
    udpSender = UdpSenderService(targetIp: ip, targetPort: port);
    await udpSender!.init();
  }

  void _startFrameSampling() {
    _timer = Timer.periodic(const Duration(milliseconds: 41), (timer) async {
      if (_controller != null && _controller!.value.isStreamingImages) {
        if (_latestImage != null) {
          frameQueue.add(_latestImage!);
          if (udpSender != null) {
            final jpegBytes = await encodeCameraImageToJpeg(_latestImage!);
            if (jpegBytes != null) {
              udpSender!.send(jpegBytes);
            }
          }
          if (onFrameSampled != null) onFrameSampled!();
        }
      }
    });
  }

  void onImage(CameraImage image) {
    _latestImage = image;
  }

  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _webSocketService?.dispose();
  }

  CameraController? get controller => _controller;
}
