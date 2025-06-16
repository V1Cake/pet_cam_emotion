import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for SystemChrome
import 'package:video_player/video_player.dart';
import '../services/csv_parser.dart';
import '../utils/video_overlay_painter.dart';

class VideoDemoScreen extends StatefulWidget {
  const VideoDemoScreen({super.key});

  @override
  State<VideoDemoScreen> createState() => _VideoDemoScreenState();
}

class _VideoDemoScreenState extends State<VideoDemoScreen> {
  late VideoPlayerController _controller;
  List<Map<String, dynamic>> _frameData = [];
  bool _isReady = false;
  VoidCallback? _listener;
  double _videoWidth = 1.0; // Default to 1.0 to avoid division by zero
  double _videoHeight = 1.0; // Default to 1.0 to avoid division by zero

  @override
  void initState() {
    super.initState();
    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initVideoAndData();
  }

  Future<void> _initVideoAndData() async {
    print('Starting video and data initialization...');
    try {
      _controller = VideoPlayerController.asset('assets/demo_video_O.mp4');
      _listener = () {
        if (_controller.value.isInitialized) {
          setState(() {}); // Redraw to update overlay with current frame data
        }
      };
      _controller.addListener(_listener!);
      await _controller.initialize();
      print('Video controller initialized.');

      // Store video dimensions
      _videoWidth = _controller.value.size.width;
      _videoHeight = _controller.value.size.height;
      print('Video dimensions: $_videoWidth x $_videoHeight');

      _frameData = await CsvParser.loadCsv('assets/Rest-Walking.csv');
      print('CSV data loaded. Total frames: ${_frameData.length}');
      setState(() {
        _isReady = true;
      });
      print('Initialization complete. _isReady set to true.');
      _controller.play(); // Auto-play video
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(
      _listener!,
    ); // Remove listener to prevent memory leaks
    _controller.dispose();
    // Reset to portrait mode when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Video Demo Testing')),
      body:
          _isReady
              ? Stack(
                alignment: Alignment.center,
                children: [
                  // Video Player
                  Positioned.fill(
                    child: FittedBox(
                      fit:
                          BoxFit.fill, // Ensures video stretches to fill bounds
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                  // Overlay Painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: VideoOverlayPainter(
                        frameData: _getCurrentFrameData(),
                        videoWidth: _videoWidth,
                        videoHeight: _videoHeight,
                        renderWidth:
                            MediaQuery.of(
                              context,
                            ).size.width, // Pass actual screen width
                        renderHeight:
                            MediaQuery.of(
                              context,
                            ).size.height, // Pass actual screen height
                      ),
                    ),
                  ),
                  // Play/Pause Button
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white, // Make button visible on video
                            size: 40.0,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Back Button
                  Positioned(
                    top: 20,
                    left: 20,
                    child: SafeArea(
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
    );
  }

  Map<String, dynamic>? _getCurrentFrameData() {
    if (_frameData.isEmpty || !_controller.value.isInitialized) {
      print(
        '_getCurrentFrameData: No frame data or controller not initialized.',
      );
      return null;
    }
    final position = _controller.value.position;
    // Assuming 30 FPS, each frame is approx 33ms
    final frameIdx = (position.inMilliseconds / 33).floor();
    print(
      '_getCurrentFrameData: current position: ${position.inMilliseconds}ms, calculated frame index: $frameIdx',
    );
    if (frameIdx < 0 || frameIdx >= _frameData.length) {
      print(
        '_getCurrentFrameData: Frame index $frameIdx out of bounds. Total frames: ${_frameData.length}',
      );
      return null;
    }
    final data = _frameData[frameIdx];
    print('_getCurrentFrameData: returning data for frame $frameIdx: $data');
    return data;
  }
}
